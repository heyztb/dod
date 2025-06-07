<script lang="ts">
	import { Network } from 'lucide-svelte';
	import { chainId, isConnected } from '$lib/stores/viem';
	import { useSwitchChain } from '$lib/hooks/useViem';
	import { base, baseSepolia } from 'viem/chains';

	const switchChain = useSwitchChain();

	// Chain switching function
	async function handleSwitchChain() {
		try {
			// Switch to the other chain (if on mainnet, go to sepolia, and vice versa)
			const targetChain = $chainId === base.id ? baseSepolia : base;
			await switchChain(targetChain);
			console.log(`Switched to ${targetChain.name}`);
		} catch (error) {
			console.error('Failed to switch chain:', error);
		}
	}

	// Get chain info for styling
	function getChainInfo(chainId: number | null) {
		switch (chainId) {
			case base.id:
				return { name: 'Base', color: 'bg-blue-500' };
			case baseSepolia.id:
				return { name: 'Base Sepolia', color: 'bg-purple-500' };
			default:
				return { name: 'Unknown', color: 'bg-gray-500' };
		}
	}

	$: chainInfo = getChainInfo($chainId);
</script>

{#if $isConnected}
	<button
		type="button"
		onclick={handleSwitchChain}
		class="btn preset-outlined-primary flex items-center gap-2 border border-blue-300 bg-white px-3 py-2 text-blue-700 hover:bg-blue-50 dark:border-blue-600 dark:bg-gray-800 dark:text-blue-200 dark:hover:bg-gray-700"
		aria-label="Switch blockchain network"
		title="Current: {chainInfo.name}"
	>
		<Network size={18} />
		<span class="hidden sm:inline">Switch Chain</span>
	</button>
{/if}
