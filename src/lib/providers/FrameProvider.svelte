<script lang="ts">
	import sdk from '@farcaster/frame-sdk';
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import { frameContext } from '$lib/stores';
	import adze from 'adze';

	const logger = adze.ns('frontend', 'FrameProvider');

	const { children } = $props();

	onMount(async () => {
		logger.info('FrameProvider mounting');
		if (!(await sdk.isInMiniApp())) {
			logger.log('not in mini app, skipping frameprovider setup');
			return;
		}
		await sdk.actions.ready();
		const context = await sdk.context;
		frameContext.set(context);
		if (!context.client.added) {
			await sdk.actions.addMiniApp();
		}

		if (!page.data.session) {
			logger.info('Attempting Quick Auth...');
			const { token } = await sdk.quickAuth.getToken();

			const quickAuthLogin = await fetch('/api/auth/quick-auth', {
				method: 'POST',
				body: JSON.stringify({ token }),
				headers: {
					'Content-Type': 'application/json'
				}
			});

			if (quickAuthLogin.ok) {
				logger.success('Quick Auth successful');
			} else {
				logger.warn('Quick Auth failed');
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
					logger.error('Failed to update user', {
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
				logger.error('Failed to update user', {
					status: res.status,
					response: await res.json()
				});
			}
		});
		logger.info('Event listeners created');
		logger.info('FrameProvider mounted');
	});
</script>

{@render children()}
