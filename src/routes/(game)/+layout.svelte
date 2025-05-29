<script lang="ts">
	import Nav from '$lib/ui/Nav.svelte';
	let { children } = $props();
</script>

{@render children()}
<Nav />
