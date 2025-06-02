<script lang="ts">
	import FrameProvider from './FrameProvider.svelte';
	import ViemProvider from './ViemProvider.svelte';
	let { children } = $props();
</script>

<FrameProvider>
	<ViemProvider>
		{@render children()}
	</ViemProvider>
</FrameProvider>
