<script lang="ts">
	import { useAccount, usePublicClient, useSwitchChain, useViemState } from '$lib/hooks/useViem';
	import { formatEther } from 'viem';
	import { base, baseSepolia } from 'viem/chains';

	const account = useAccount();
	const publicClient = usePublicClient();

	const switchChain = useSwitchChain();
	const viemState = useViemState();

	let balance = $state<string | null>(null);
	let isLoadingBalance = $state(false);

	// Get balance when account or public client changes
	$effect(() => {
		const loadBalance = async () => {
			if ($account.address && $publicClient && $account.isConnected) {
				isLoadingBalance = true;
				try {
					const bal = await $publicClient.getBalance({
						address: $account.address
					});
					balance = formatEther(bal);
				} catch (error) {
					console.error('Failed to get balance:', error);
					balance = null;
				} finally {
					isLoadingBalance = false;
				}
			} else {
				balance = null;
			}
		};

		loadBalance();
	});

	async function handleSwitchChain(chain: typeof base | typeof baseSepolia) {
		try {
			await switchChain(chain);
		} catch (error) {
			console.error('Failed to switch chain:', error);
		}
	}

	function getChainName(chainId: number | null): string {
		switch (chainId) {
			case base.id:
				return 'Base';
			case baseSepolia.id:
				return 'Base Sepolia';
			default:
				return 'Unknown Chain';
		}
	}

	function shortenAddress(address: string): string {
		return `${address.slice(0, 6)}...${address.slice(-4)}`;
	}
</script>

<div class="wallet-info rounded-lg border bg-gray-100 p-4 shadow-sm dark:bg-gray-800">
	<h3 class="mb-4 text-lg font-semibold">Wallet Information</h3>

	{#if $viemState.isConnecting}
		<div class="py-4 text-center">
			<div class="mx-auto h-8 w-8 animate-spin rounded-full border-b-2 border-blue-500"></div>
			<p class="mt-2 text-gray-900 dark:text-gray-100">Connecting...</p>
		</div>
	{:else if $viemState.error}
		<div class="rounded-md border border-red-200 bg-red-50 p-4">
			<p class="text-sm text-red-700">Error: {$viemState.error}</p>
		</div>
	{:else if $account.isConnected}
		<div class="space-y-3">
			<!-- Address -->
			<div class="flex items-center justify-between">
				<span class="text-gray-900 dark:text-gray-100">Address:</span>
				<code class="rounded bg-gray-100 px-2 py-1 text-sm dark:bg-gray-800">
					{$account.address ? shortenAddress($account.address) : 'N/A'}
				</code>
			</div>

			<!-- Chain -->
			<div class="flex items-center justify-between">
				<span class="text-gray-900 dark:text-gray-100">Chain:</span>
				<span class="font-medium">{getChainName($account.chainId)}</span>
			</div>

			<!-- Balance -->
			<div class="flex items-center justify-between">
				<span class="text-gray-900 dark:text-gray-100">Balance:</span>
				{#if isLoadingBalance}
					<span class="text-gray-400">Loading...</span>
				{:else if balance !== null}
					<span class="font-medium">{parseFloat(balance).toFixed(4)} ETH</span>
				{:else}
					<span class="text-gray-400">Failed to load</span>
				{/if}
			</div>

			<!-- Chain Switching -->
			<div class="border-t pt-4">
				<p class="mb-2 text-sm text-gray-900 dark:text-gray-100">Switch Chain:</p>
				<div class="flex gap-2">
					<button
						onclick={() => handleSwitchChain(base)}
						disabled={$account.chainId === base.id}
						class="rounded bg-blue-500 px-3 py-2 text-sm text-white hover:bg-blue-600 disabled:cursor-not-allowed disabled:bg-gray-300"
					>
						Base
					</button>
					<button
						onclick={() => handleSwitchChain(baseSepolia)}
						disabled={$account.chainId === baseSepolia.id}
						class="rounded bg-purple-500 px-3 py-2 text-sm text-white hover:bg-purple-600 disabled:cursor-not-allowed disabled:bg-gray-300"
					>
						Base Sepolia
					</button>
				</div>
			</div>

			<!-- Debug Info -->
			<details class="border-t pt-4">
				<summary class="cursor-pointer text-sm text-gray-900 dark:text-gray-100">Debug Info</summary
				>
				<pre class="mt-2 overflow-auto rounded bg-gray-100 p-2 text-xs dark:bg-gray-800">
{JSON.stringify($viemState, null, 2)}
				</pre>
			</details>
		</div>
	{:else}
		<div class="py-4 text-center">
			<p class="text-gray-600">Wallet not connected</p>
			<p class="mt-1 text-sm text-gray-500">
				The wallet will automatically connect when the Farcaster frame is ready.
			</p>
		</div>
	{/if}
</div>

<style>
	.wallet-info {
		max-width: 400px;
	}
</style>
