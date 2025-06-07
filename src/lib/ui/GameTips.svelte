<script lang="ts">
	import { Lightbulb, ChevronLeft, ChevronRight, Dice1 } from 'lucide-svelte';

	// Array of game tips and strategies based on expert advice
	const tips = [
		{
			title: 'Master the Scoring Rules',
			content:
				'Know your scoring combinations: 1s = 100, 5s = 50, three 4s = 400, straight = 1,500. Missing a three-of-a-kind or not spotting a straight can cost you the game.',
			type: 'scoring'
		},
		{
			title: 'Start Conservatively Early',
			content:
				'Bank 300-500 points after one or two rolls in early game. This builds steady score and avoids early farkle disasters while you learn the flow.',
			type: 'strategy'
		},
		{
			title: 'Take Calculated Risks When Behind',
			content:
				'If trailing (opponent at 8,000, you at 5,000), push your luck after setting aside decent points. Weigh potential big combos against farkle risk.',
			type: 'strategy'
		},
		{
			title: 'Watch the Dice Count',
			content:
				'Fewer dice = higher farkle chance. With 1-2 dice and 400+ points, bank it! One die has 2/3 chance of failing (only 1 or 5 scores).',
			type: 'strategy'
		},
		{
			title: 'Avoid Greed Trap',
			content:
				'Hit three 1s (1,000 points)? Bank it! The temptation to "keep going" often leads to farkle and losing everything you worked for.',
			type: 'strategy'
		},
		{
			title: 'Adapt to the Scoreboard',
			content:
				"Leading at 8,000? Play safe with smaller banks. Opponent at 9,800 and you're at 7,000? Go for broke - roll aggressively!",
			type: 'strategy'
		},
		{
			title: 'Three of a Kind Values',
			content:
				'Three 1s = 1,000 (highest), three 2s = 200, three 3s = 300, three 4s = 400, three 5s = 500, three 6s = 600. Memorize these for quick decisions.',
			type: 'scoring'
		},
		{
			title: 'Embrace the Luck Factor',
			content:
				"Farkle is chance-based. You can play perfectly and still farkle three times in a row. Stay calm, adjust strategy, and don't let bad rolls rattle you.",
			type: 'mindset'
		}
	];

	let currentTipIndex = $state(0);
	let isAnimating = $state(false);

	// Auto-rotate tips every 8 seconds
	let intervalId: ReturnType<typeof setInterval>;

	$effect(() => {
		intervalId = setInterval(() => {
			nextTip();
		}, 8000);

		return () => {
			if (intervalId) {
				clearInterval(intervalId);
			}
		};
	});

	function nextTip() {
		if (isAnimating) return;
		isAnimating = true;
		setTimeout(() => {
			currentTipIndex = (currentTipIndex + 1) % tips.length;
			isAnimating = false;
		}, 150);
	}

	function prevTip() {
		if (isAnimating) return;
		isAnimating = true;
		setTimeout(() => {
			currentTipIndex = currentTipIndex === 0 ? tips.length - 1 : currentTipIndex - 1;
			isAnimating = false;
		}, 150);
	}

	const currentTip = $derived(tips[currentTipIndex]);
</script>

<div class="rounded-lg">
	<div class="mb-4 flex items-center justify-between">
		<div class="flex items-center gap-2">
			<Lightbulb size={20} class="text-yellow-500" />
			<h3 class="font-semibold text-gray-900 dark:text-gray-100">Game Tips</h3>
		</div>

		<div class="flex items-center gap-2">
			<button
				onclick={() => {
					console.log('Previous button clicked');
					prevTip();
				}}
				class="relative z-10 flex items-center justify-center rounded-md bg-gray-100 p-2 text-gray-700 shadow-sm transition-all hover:bg-gray-200 hover:shadow-md dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
				style="min-width: 36px; min-height: 36px;"
				aria-label="Previous tip"
			>
				<ChevronLeft size={18} />
			</button>
			<button
				onclick={() => {
					console.log('Next button clicked');
					nextTip();
				}}
				class="relative z-10 flex items-center justify-center rounded-md bg-gray-100 p-2 text-gray-700 shadow-sm transition-all hover:bg-gray-200 hover:shadow-md dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
				style="min-width: 36px; min-height: 36px;"
				aria-label="Next tip"
			>
				<ChevronRight size={18} />
			</button>
		</div>
	</div>

	<div
		class="min-h-[80px] transition-opacity duration-150 {isAnimating
			? 'opacity-50'
			: 'opacity-100'}"
	>
		<div class="mb-2 flex items-center gap-2">
			<div class="flex items-center gap-1">
				{#if currentTip.type === 'strategy'}
					<div
						class="rounded bg-blue-100 px-2 py-1 text-xs font-medium text-blue-800 dark:bg-blue-900 dark:text-blue-200"
					>
						Strategy
					</div>
				{:else if currentTip.type === 'scoring'}
					<div
						class="rounded bg-green-100 px-2 py-1 text-xs font-medium text-green-800 dark:bg-green-900 dark:text-green-200"
					>
						Scoring
					</div>
				{:else if currentTip.type === 'mindset'}
					<div
						class="rounded bg-purple-100 px-2 py-1 text-xs font-medium text-purple-800 dark:bg-purple-900 dark:text-purple-200"
					>
						Mindset
					</div>
				{/if}
			</div>
		</div>

		<h4 class="mb-2 font-medium text-gray-900 dark:text-gray-100">
			{currentTip.title}
		</h4>

		<p class="text-sm leading-relaxed text-gray-600 dark:text-gray-300">
			{currentTip.content}
		</p>
	</div>

	<!-- Progress dots -->
	<div class="mt-4 flex justify-center gap-2">
		{#each tips as _, index}
			<button
				onclick={() => {
					console.log(`Progress dot ${index + 1} clicked`);
					if (!isAnimating) {
						currentTipIndex = index;
					}
				}}
				class="relative z-10 h-3 w-3 rounded-full transition-all {index === currentTipIndex
					? 'scale-110 bg-blue-500'
					: 'bg-gray-300 hover:scale-105 hover:bg-gray-400 dark:bg-gray-600 dark:hover:bg-gray-500'}"
				style="min-width: 12px; min-height: 12px;"
				aria-label="Go to tip {index + 1}"
			></button>
		{/each}
	</div>
</div>
