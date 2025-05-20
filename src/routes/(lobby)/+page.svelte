<script lang="ts">
	import { page } from '$app/state';
	import { frameContext } from '$lib/stores';
</script>

<div class="container mx-auto p-4">
	<h1 class="mb-4 text-3xl font-bold">Welcome {$frameContext?.user?.displayName || ''}</h1>
	<p class="mb-4">
		Visit <a href="https://svelte.dev/docs/kit" class="text-blue-500 hover:underline"
			>svelte.dev/docs/kit</a
		> to read the documentation
	</p>

	<div class="rounded-lg bg-gray-100 p-4">
		<h2 class="mb-4 text-2xl font-semibold">Frame Context</h2>

		{#if $frameContext}
			<div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
				<!-- User Section -->
				<div class="rounded bg-white p-4 shadow">
					<h3 class="mb-2 text-lg font-bold">User</h3>
					{#if $frameContext.user}
						<div class="mb-3 flex items-center gap-3">
							{#if $frameContext.user.pfpUrl}
								<img src={$frameContext.user.pfpUrl} alt="Profile" class="h-12 w-12 rounded-full" />
							{/if}
							<div>
								<p class="font-bold">{$frameContext.user.displayName || ''}</p>
								<p class="text-gray-600">@{$frameContext.user.username || ''}</p>
							</div>
						</div>
						<div class="space-y-1">
							<p><span class="font-semibold">FID:</span> {$frameContext.user.fid}</p>
							{#if $frameContext.user.location?.description}
								<p>
									<span class="font-semibold">Location:</span>
									{$frameContext.user.location.description}
								</p>
							{/if}
						</div>
					{:else}
						<p>No user data available</p>
					{/if}
				</div>

				<!-- Location Section -->
				<div class="rounded bg-white p-4 shadow">
					<h3 class="mb-2 text-lg font-bold">Location</h3>
					{#if $frameContext.location}
						<p><span class="font-semibold">Type:</span> {$frameContext.location.type}</p>
					{:else}
						<p>No location data available</p>
					{/if}
				</div>

				<!-- Client Section -->
				<div class="rounded bg-white p-4 shadow">
					<h3 class="mb-2 text-lg font-bold">Client</h3>
					{#if $frameContext.client}
						<p><span class="font-semibold">Client FID:</span> {$frameContext.client.clientFid}</p>
						<p>
							<span class="font-semibold">Added:</span>
							{$frameContext.client.added ? 'Yes' : 'No'}
						</p>
					{:else}
						<p>No client data available</p>
					{/if}
				</div>
			</div>

			<details class="mt-4">
				<summary class="cursor-pointer text-sm text-gray-600">Show raw JSON</summary>
				<pre
					class="mt-2 overflow-x-auto rounded bg-gray-800 p-2 text-xs text-white">{JSON.stringify(
						$frameContext,
						null,
						2
					)}</pre>
			</details>
		{:else}
			<p>No frame context available</p>
		{/if}
	</div>
</div>
