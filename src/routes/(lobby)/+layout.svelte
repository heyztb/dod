<script lang="ts">
	import Nav from '$lib/ui/Nav.svelte';
	const FrameProvider = import('$lib/providers/FrameProvider.svelte');
	let { children } = $props();
</script>

{#if FrameProvider}
	{#await FrameProvider then F}
		{@const FrameProviderComponent = F.default}
		<FrameProviderComponent>
			{@render children()}
			<Nav />
		</FrameProviderComponent>
	{/await}
{/if}
