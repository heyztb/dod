<script lang="ts">
	import { frameContext } from '$lib/stores';
	import { Book, Network } from 'lucide-svelte';
	import Modal from '$lib/ui/Modal.svelte';
	import { address, chainId, isConnected, viemStore } from '$lib/stores/viem';
	import { useSwitchChain } from '$lib/hooks/useViem';
	import { base, baseSepolia } from 'viem/chains';

	let showRulesModal = $state(false);

	const switchChain = useSwitchChain();

	// Add chain switching function
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

	// Add function to get chain info
	function getChainInfo(chainId: number | null) {
		switch (chainId) {
			case base.id:
				return { color: 'bg-blue-500' };
			case baseSepolia.id:
				return { color: 'bg-purple-500' };
			default:
				return { color: 'bg-gray-500' };
		}
	}

	// Console log wallet information when it changes
	$effect(() => {
		if ($isConnected) {
			console.log('Wallet Connected:', {
				address: $address,
				chainId: $chainId,
				isConnected: $isConnected
			});
		} else {
			console.log('Wallet not connected');
		}
	});

	// Console log any viem state changes
	$effect(() => {
		console.log('Viem State:', $viemStore);
	});
</script>

<div class="container mx-auto p-4 pb-20">
	<div class="mb-6 flex items-center justify-between">
		<h1 class="text-3xl font-bold text-gray-900 dark:text-gray-100">
			Welcome {$frameContext?.user?.displayName || ''}
		</h1>

		<div class="flex gap-2">
			<!-- Add chain switch button -->
			{#if $isConnected}
				<button
					type="button"
					onclick={handleSwitchChain}
					class="btn preset-outlined-primary flex items-center gap-2 border border-blue-300 bg-white px-3 py-2 text-blue-700 hover:bg-blue-50 dark:border-blue-600 dark:bg-gray-800 dark:text-blue-200 dark:hover:bg-gray-700"
					aria-label="Switch blockchain network"
				>
					<Network size={18} />
					<span class="hidden sm:inline">Switch Chain</span>
				</button>
			{/if}

			<!-- Rules button -->
			<button
				type="button"
				class="btn preset-outlined-neutral-200-800 flex items-center gap-2 border border-gray-300 bg-white p-3 text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
				onclick={() => (showRulesModal = true)}
				aria-label="View game rules"
			>
				<Book size={20} />
				<span class="hidden sm:inline">Rules</span>
			</button>
		</div>
	</div>

	<!-- Main content area -->
	<div class="rounded-lg bg-gray-100 p-6 dark:bg-gray-800">
		<h2 class="mb-4 text-2xl font-semibold text-gray-900 dark:text-gray-100">Ready to Play?</h2>
		<p class="mb-6 text-lg text-gray-700 dark:text-gray-300">
			Roll six dice to score points. First to 10,000, or highest score wins!
		</p>

		<!-- Game Action Buttons -->
		<div class="mx-auto flex max-w-md flex-col gap-4 space-y-2 sm:flex-row sm:gap-6">
			<button
				type="button"
				class="btn preset-filled flex-1 px-6 py-4 text-lg font-semibold transition-all duration-200 ease-in-out hover:scale-105"
				onclick={() => console.log('Host Game clicked')}
			>
				🎲 Host Game
			</button>

			<button
				type="button"
				class="btn preset-outlined-surface-950-50 flex-1 px-6 py-4 text-lg font-semibold transition-all duration-200 ease-in-out hover:scale-105"
				onclick={() => console.log('Join Game clicked')}
			>
				👥 Join Game
			</button>
		</div>
	</div>
</div>

<!-- Chain Status Banner - Fixed at bottom -->
{#if $isConnected}
	{@const chainInfo = getChainInfo($chainId)}
	<div class="fixed right-0 bottom-0 left-0 {chainInfo.color} px-4 py-3 shadow-lg">
		<div class="container mx-auto flex items-center justify-between"></div>
	</div>
{:else}
	<div class="fixed right-0 bottom-0 left-0 bg-gray-500 px-4 py-3 shadow-lg">
		<div class="container mx-auto flex items-center justify-center"></div>
	</div>
{/if}

<!-- Rules Modal -->
<Modal bind:open={showRulesModal} title="Farkle Rules">
	<div class="space-y-6">
		<!-- YouTube Video Embed -->
		<div class="aspect-video w-full overflow-hidden rounded-lg">
			<iframe
				src="https://www.youtube.com/embed/EvWcUDYB9wQ"
				title="How to Play Farkle"
				class="h-full w-full"
				frameborder="0"
				allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
				allowfullscreen
			></iframe>
		</div>

		<p class="text-lg text-gray-700 dark:text-gray-300">
			Roll six dice to score points. First to 10,000, or highest score wins!
		</p>

		<div class="grid gap-6 md:grid-cols-2">
			<div>
				<h3 class="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">How to Play</h3>
				<ul class="list-disc space-y-2 pl-5 text-gray-700 dark:text-gray-300">
					<li>Roll all six dice</li>
					<li>Set aside scoring dice</li>
					<li>Roll remaining dice or bank points</li>
					<li>No scoring dice = "Farkle" (lose turn points)</li>
					<li>Score all six dice = roll again</li>
					<li>
						After a player reaches 10,000 points, other players have one last turn to try to surpass
						their score
					</li>
				</ul>
			</div>

			<div>
				<h3 class="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">Scoring</h3>
				<ul class="list-disc space-y-1 pl-5 text-sm text-gray-700 dark:text-gray-300">
					<li>Single 1 = 100 points</li>
					<li>Single 5 = 50 points</li>
					<li>Three 1s = 1,000 points</li>
					<li>Three of a kind (2-6) = 100 × number</li>
					<li>Four of a kind = 1,000 points</li>
					<li>Five of a kind = 2,000 points</li>
					<li>Six of a kind = 3,000 points</li>
					<li>Straight (1-6) = 1,500 points</li>
					<li>Three pairs = 1,500 points</li>
					<li>Four of a kind + pair = 1,500 points</li>
					<li>Two three of a kinds = 2,500 points</li>
				</ul>
			</div>
		</div>
	</div>
</Modal>
