<script lang="ts">
	import Button from './ui/button.svelte';
	import { page } from '$app/state';
	const getActiveClass = (path: string) => {
		return page.url.pathname === path
			? 'text-rose-500 dark:text-rose-400'
			: 'text-gray-500 dark:text-gray-400 hover:text-rose-500 dark:hover:text-rose-400';
	};
</script>

<nav class="flex flex-row justify-between">
	<a href="/">
		<Button>Lobby</Button>
	</a>
	<a href="/game">
		<Button>Game</Button>
	</a>
</nav>
