<script lang="ts">
	import { Trophy, Target, TrendingUp, Zap } from 'lucide-svelte';

	// Mock data for now - in a real app this would come from a store or API
	let playerStats = $state({
		gamesPlayed: 47,
		bestScore: 8750,
		winRate: 68,
		currentStreak: 3,
		averageScore: 4230,
		totalWins: 32
	});

	// Calculate some derived stats
	const winPercentage = $derived(
		Math.round((playerStats.totalWins / playerStats.gamesPlayed) * 100)
	);
</script>

<div class="rounded-lg">
	<div class="mb-4 flex items-center gap-2">
		<Trophy size={20} class="text-yellow-600" />
		<h3 class="font-semibold text-gray-900 dark:text-gray-100">Your Stats</h3>
	</div>

	<div class="grid grid-cols-2 gap-4">
		<!-- Games Played -->
		<div class="text-center">
			<div class="mb-1 flex items-center justify-center gap-1">
				<Target size={16} class="text-blue-600" />
				<span class="text-xs text-gray-600 dark:text-gray-300">Games</span>
			</div>
			<div class="text-lg font-bold text-gray-900 dark:text-gray-100">
				{playerStats.gamesPlayed}
			</div>
		</div>

		<!-- Best Score -->
		<div class="text-center">
			<div class="mb-1 flex items-center justify-center gap-1">
				<TrendingUp size={16} class="text-green-600" />
				<span class="text-xs text-gray-600 dark:text-gray-300">Best</span>
			</div>
			<div class="text-lg font-bold text-gray-900 dark:text-gray-100">
				{playerStats.bestScore.toLocaleString()}
			</div>
		</div>

		<!-- Win Rate -->
		<div class="text-center">
			<div class="mb-1 flex items-center justify-center gap-1">
				<Trophy size={16} class="text-purple-600" />
				<span class="text-xs text-gray-600 dark:text-gray-300">Win Rate</span>
			</div>
			<div class="text-lg font-bold text-gray-900 dark:text-gray-100">
				{winPercentage}%
			</div>
		</div>

		<!-- Current Streak -->
		<div class="text-center">
			<div class="mb-1 flex items-center justify-center gap-1">
				<Zap size={16} class="text-orange-600" />
				<span class="text-xs text-gray-600 dark:text-gray-300">Streak</span>
			</div>
			<div class="text-lg font-bold text-gray-900 dark:text-gray-100">
				{playerStats.currentStreak}
			</div>
		</div>
	</div>

	<!-- Progress towards next milestone -->
	<div class="mt-4 border-t border-gray-200 pt-3 dark:border-gray-600">
		<div class="mb-2 flex items-center justify-between text-xs">
			<span class="text-gray-600 dark:text-gray-300">Next milestone</span>
			<span class="text-gray-600 dark:text-gray-300">{playerStats.gamesPlayed}/50 games</span>
		</div>
		<div class="h-2 w-full rounded-full bg-gray-200 dark:bg-gray-700">
			<div
				class="h-2 rounded-full bg-gradient-to-r from-orange-500 to-red-600 transition-all duration-300"
				style="width: {(playerStats.gamesPlayed / 50) * 100}%"
			></div>
		</div>
		<p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
			{50 - playerStats.gamesPlayed} games until next achievement
		</p>
	</div>
</div>
