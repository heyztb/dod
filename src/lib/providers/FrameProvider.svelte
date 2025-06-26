<script lang="ts">
    import sdk from '@farcaster/frame-sdk';
    import { onMount } from 'svelte';
    import { error } from '@sveltejs/kit';
    import { page } from '$app/state';
    import { frameContext } from '$lib/stores';

    const { children } = $props();

    onMount(async () => {
        console.log('FrameProvider mounting');
        await sdk.actions.ready();
        const context = await sdk.context;
        frameContext.set(context);
        if (!context.client.added) {
            await sdk.actions.addMiniApp(); // Updated method name
        }

        if (!page.data.session) {
            try {
                // Try Quick Auth first (better UX, no manual verification needed)
                console.log('Attempting Quick Auth...');
                const { token } = await sdk.actions.quickAuth();

                const quickAuthLogin = await fetch('/api/auth/quick-auth', {
                    method: 'POST',
                    body: JSON.stringify({ token }),
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });

                if (quickAuthLogin.ok) {
                    console.log('Quick Auth successful');
                    // Reload to get updated session data
                    window.location.reload();
                    return;
                } else {
                    console.warn('Quick Auth failed, falling back to legacy auth');
                }
            } catch (quickAuthError) {
                console.warn('Quick Auth not available, using legacy auth:', quickAuthError);
            }

            // Fallback to legacy SIWF flow
            console.log('Using legacy SIWF authentication...');
            const csrf = await fetch('/api/auth/csrf', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            if (!csrf.ok) {
                console.error('Failed to get nonce', {
                    status: csrf.status,
                    response: await csrf.json()
                });
                error(csrf.status, 'Failed to get nonce');
            }
            const { nonce } = await csrf.json();
            const signInResult = await sdk.actions.signIn({ nonce, acceptAuthAddress: true });
            const login = await fetch('/api/auth/siwf', {
                method: 'POST',
                body: JSON.stringify({
                    message: signInResult.message,
                    signature: signInResult.signature,
                    authMethod: signInResult.authMethod,
                    nonce
                }),
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            if (!login.ok) {
                console.error('Failed to login', {
                    status: login.status,
                    response: await login.json()
                });
                error(login.status, 'Failed to login');
            }
        }

        sdk.on('frameAdded', async ({ notificationDetails }) => {
            if (notificationDetails) {
                const { token, url } = notificationDetails;
                const res = await fetch('/api/user', {
                    method: 'PATCH',
                    body: JSON.stringify({ token, url })
                });
                if (!res.ok) {
                    console.error('Failed to update user', {
                        status: res.status,
                        response: await res.json()
                    });
                }
            }
        });

        sdk.on('frameRemoved', async () => {
            if (!page.data.user?.notificationDetails) {
                return;
            }
            const res = await fetch('/api/user', {
                method: 'PATCH',
                body: JSON.stringify({ token: null, url: null })
            });
            if (!res.ok) {
                console.error('Failed to update user', {
                    status: res.status,
                    response: await res.json()
                });
            }
        });
        console.log('FrameProvider mounted');
    });
</script>

{@render children()}
