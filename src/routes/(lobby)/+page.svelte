<script lang="ts">
	import { page } from '$app/state';
	import { frameContext } from '$lib/stores';
	import { Book } from 'lucide-svelte';
	import Modal from '$lib/ui/Modal.svelte';

	let showRulesModal = $state(false);
</script>

<div class="container mx-auto p-4">
	<div class="mb-6 flex items-center justify-between">
		<h1 class="text-3xl font-bold text-gray-900 dark:text-gray-100">
			Welcome {$frameContext?.user?.displayName || ''}
		</h1>

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

	<!-- Main content area -->
	<div class="rounded-lg bg-gray-100 p-6 dark:bg-gray-800">
		<h2 class="mb-4 text-2xl font-semibold text-gray-900 dark:text-gray-100">Ready to Play?</h2>
		<p class="text-lg text-gray-700 dark:text-gray-300">
			Roll six dice to score points. First to 10,000, or highest score wins!
		</p>
	</div>
</div>

<!-- Rules Modal -->
<Modal bind:open={showRulesModal} title="Farkle Rules">
	<div class="space-y-6">
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
					<li>Three of a kind = 100 × number</li>
					<li>Straight (1-6) = 1,500 points</li>
					<li>Three pairs = 1,500 points</li>
				</ul>
			</div>
		</div>
	</div>
</Modal>
