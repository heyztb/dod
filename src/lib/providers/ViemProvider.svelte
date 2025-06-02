<script lang="ts">
	import { setContext } from 'svelte';
	import { viemStore } from '$lib/stores/viem';
	import { frameContext } from '$lib/stores';
	import { onMount } from 'svelte';
	import sdk from '@farcaster/frame-sdk';

	const { children } = $props();

	// Set the viem store in context
	setContext('viem', viemStore);

	// Initialize when frame context is available
	let initialized = false;

	$effect(() => {
		if ($frameContext && !initialized) {
			initialized = true;
			viemStore.initialize();
		}
	});

	onMount(() => {
		// Listen for account/chain changes from the provider
		if (typeof window !== 'undefined') {
			if (sdk.wallet?.ethProvider) {
				sdk.wallet.ethProvider.on?.('accountsChanged', () => {
					viemStore.initialize();
				});

				sdk.wallet.ethProvider.on?.('chainChanged', () => {
					viemStore.initialize();
				});
			}
		}
	});
</script>

{@render children()}
