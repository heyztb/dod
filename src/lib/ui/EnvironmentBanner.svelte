<script lang="ts">
	import { environmentStore, isInMiniApp, miniAppContext } from '$lib/stores/environment';
	import { Smartphone, Globe, Loader2, AlertCircle } from 'lucide-svelte';

	$: environment = $environmentStore;
	$: isMiniApp = $isInMiniApp;
	$: context = $miniAppContext;
</script>

<!-- Only show banner when NOT in MiniApp -->
{#if environment.isDetecting}
	<div
		class="mb-4 rounded-lg border border-blue-200 bg-blue-50 p-3 text-sm dark:border-blue-800 dark:bg-blue-900/20"
	>
		<div class="flex items-center gap-2 text-blue-600 dark:text-blue-400">
			<Loader2 size={16} class="animate-spin" />
			<span>Detecting environment...</span>
		</div>
	</div>
{:else if environment.error || (!isMiniApp && environment.hasDetected)}
	<div
		class="mb-4 rounded-lg border border-blue-200 bg-blue-50 p-3 text-sm dark:border-blue-800 dark:bg-blue-900/20"
	>
		<div class="flex items-center gap-2 text-blue-600 dark:text-blue-400">
			<Globe size={16} />
			<div>
				<div class="font-medium">Running as standalone web app</div>
				<div class="text-xs opacity-75">
					🚀 For the best experience, open this in the Farcaster app
				</div>
			</div>
		</div>
	</div>
{/if}
