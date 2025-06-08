<script lang="ts">
	import { environmentStore, isInMiniApp, miniAppContext } from '$lib/stores/environment';
	import { Smartphone, Globe, Loader2, AlertCircle } from 'lucide-svelte';

	$: environment = $environmentStore;
	$: isMiniApp = $isInMiniApp;
	$: context = $miniAppContext;
</script>

<div class="mb-4 rounded-lg border p-3 text-sm">
	{#if environment.isDetecting}
		<div class="flex items-center gap-2 text-blue-600 dark:text-blue-400">
			<Loader2 size={16} class="animate-spin" />
			<span>Detecting environment...</span>
		</div>
	{:else if environment.error}
		<div class="flex items-center gap-2 text-amber-600 dark:text-amber-400">
			<AlertCircle size={16} />
			<span>Detection failed - assuming web app</span>
		</div>
	{:else if isMiniApp}
		<div class="flex items-center gap-2 text-green-600 dark:text-green-400">
			<Smartphone size={16} />
			<div>
				<div class="font-medium">Running as Farcaster MiniApp</div>
				{#if context?.user}
					<div class="text-xs opacity-75">
						Welcome, {context.user.displayName || `FID: ${context.user.fid}`}
					</div>
				{/if}
			</div>
		</div>
	{:else}
		<div class="flex items-center gap-2 text-blue-600 dark:text-blue-400">
			<Globe size={16} />
			<div>
				<div class="font-medium">Running as standalone web app</div>
				<div class="text-xs opacity-75">Visit on Farcaster for the full MiniApp experience</div>
			</div>
		</div>
	{/if}
</div>
