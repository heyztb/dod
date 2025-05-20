<script lang="ts">
	let { children } = $props();
</script>

<button class="rounded-md bg-blue-500 px-4 py-2 text-white">
	{@render children()}
</button>
