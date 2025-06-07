<script lang="ts">
	import { chainId, isConnected } from '$lib/stores/viem';
	import { base, baseSepolia } from 'viem/chains';

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
	<div class="fixed right-0 bottom-0 left-0 {chainInfo.color} px-4 py-3 shadow-lg">
		<div class="container mx-auto flex items-center justify-center">
			<span class="font-medium text-white">Connected to {chainInfo.name}</span>
		</div>
	</div>
{:else}
	<div class="fixed right-0 bottom-0 left-0 bg-gray-500 px-4 py-3 shadow-lg">
		<div class="container mx-auto flex items-center justify-center">
			<span class="font-medium text-white">Wallet not connected</span>
		</div>
	</div>
{/if}
