<script lang="ts">
	import sdk from '@farcaster/frame-sdk';
	import { onMount } from 'svelte';
	import { error } from '@sveltejs/kit';
	import { page } from '$app/state';
	import { frameContext } from '$lib/stores';
	import { getLogger } from '@logtape/logtape';

	const logger = getLogger(['frontend', 'FrameProvider']);
	const { children } = $props();

	onMount(async () => {
		logger.info('FrameProvider mounted');
		await sdk.actions.ready();
		const context = await sdk.context;
		frameContext.set(context);
		if (!context.client.added) {
			await sdk.actions.addFrame();
		}
		if (!page.data.session) {
			const csrf = await fetch('/api/auth/csrf', {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json'
				}
			});
			if (!csrf.ok) {
				logger.error('Failed to get nonce', { status: csrf.status });
				error(csrf.status, 'Failed to get nonce');
			}
			const { nonce } = await csrf.json();
			const signInResult = await sdk.actions.signIn({ nonce, acceptAuthAddress: true });
			const login = await fetch('/api/auth/login', {
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
				const { error } = await login.json();
				logger.error('Failed to login', { status: login.status, error });
				error(login.status, error);
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
					const { error } = await res.json();
					logger.error('Failed to update user', { status: res.status, error });
					error(res.status, error);
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
				const { error } = await res.json();
				logger.error('Failed to update user', { status: res.status, error });
				error(res.status, error);
			}
		});
	});
</script>

{@render children()}
