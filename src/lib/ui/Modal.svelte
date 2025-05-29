<script lang="ts">
	import { X } from 'lucide-svelte';
	import { fade, scale } from 'svelte/transition';
	import { cubicOut } from 'svelte/easing';

	let { open = $bindable(false), title, children } = $props();

	function closeModal() {
		open = false;
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Escape') {
			closeModal();
		}
	}

	function handleBackdropClick(event: MouseEvent) {
		if (event.target === event.currentTarget) {
			closeModal();
		}
	}
</script>

<svelte:window onkeydown={handleKeydown} />

{#if open}
	<!-- Modal backdrop with better spacing -->
	<div
		class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 pb-24"
		onclick={handleBackdropClick}
		role="dialog"
		aria-modal="true"
		tabindex="-1"
		aria-labelledby={title ? 'modal-title' : undefined}
		in:fade={{ duration: 200, easing: cubicOut }}
		out:fade={{ duration: 150, easing: cubicOut }}
	>
		<!-- Modal content -->
		<div
			class="relative flex max-h-[80vh] w-full max-w-2xl flex-col rounded-lg bg-gray-100 shadow-xl dark:bg-gray-800"
			onclick={(e) => e.stopPropagation()}
			in:scale={{
				duration: 200,
				delay: 100,
				start: 0.95,
				easing: cubicOut
			}}
			out:scale={{
				duration: 150,
				start: 0.95,
				easing: cubicOut
			}}
		>
			<!-- Modal header -->
			{#if title}
				<div
					class="flex flex-shrink-0 items-center justify-between border-b border-gray-200 px-6 py-4 dark:border-gray-700"
				>
					<h2 id="modal-title" class="text-xl font-semibold text-gray-900 dark:text-gray-100">
						{title}
					</h2>
					<button
						type="button"
						class="rounded-sm p-1 text-gray-400 transition-colors duration-150 hover:text-gray-600 focus:ring-2 focus:ring-blue-500 focus:outline-none dark:text-gray-500 dark:hover:text-gray-300"
						onclick={closeModal}
						aria-label="Close modal"
					>
						<X size={20} />
					</button>
				</div>
			{/if}

			<!-- Modal body with scrolling and extra padding -->
			<div class="min-h-0 flex-1 overflow-y-auto px-6 py-4 pb-6">
				{@render children()}
			</div>
		</div>
	</div>
{/if}
