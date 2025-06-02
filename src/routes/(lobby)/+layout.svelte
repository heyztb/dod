<script lang="ts">
	import Nav from '$lib/ui/Nav.svelte';
	const AppProvider = import('$lib/providers/AppProvider.svelte');
	let { children } = $props();
</script>

{#if AppProvider}
	{#await AppProvider then P}
		{@const Provider = P.default}
		<Provider>
			{@render children()}
			<Nav />
		</Provider>
	{/await}
{/if}
