<script lang="ts">
    import { frameContext } from '$lib/stores';
    import { Book } from 'lucide-svelte';
    import Modal from '$lib/ui/Modal.svelte';
    import ChainSwitchButton from '$lib/ui/ChainSwitchButton.svelte';
    import ChainStatusBanner from '$lib/ui/ChainStatusBanner.svelte';
    import PlayerStats from '$lib/ui/PlayerStats.svelte';
    import GameTips from '$lib/ui/GameTips.svelte';
    import EnvironmentBanner from '$lib/ui/EnvironmentBanner.svelte';
    import { address, chainId, isConnected, viemStore } from '$lib/stores/viem';

    let showRulesModal = $state(false);

    // Console log wallet information when it changes
    $effect(() => {
        if ($isConnected) {
            console.log('Wallet Connected:', {
                address: $address,
                chainId: $chainId,
                isConnected: $isConnected
            });
        } else {
            console.log('Wallet not connected');
        }
    });

    // Console log any viem state changes
    $effect(() => {
        console.log('Viem State:', $viemStore);
    });
</script>

<div class="bg-surface-50-950 min-h-screen bg-gradient-to-br">
    <div class="container mx-auto p-4 pb-20">
        <div class="mb-8 flex items-center justify-between">
            <h1 class="text-3xl font-bold text-gray-900 dark:text-gray-100">
                Welcome {$frameContext?.user?.displayName || ''}
            </h1>

            <div class="flex gap-2">
                <!-- Chain switch button -->
                <ChainSwitchButton />

                <!-- Rules button -->
                <button
                    type="button"
                    class="btn preset-outlined-neutral-200-800 flex items-center gap-2 border border-gray-300/50 bg-white/80 p-3 text-gray-700 backdrop-blur-sm transition-all duration-200 hover:bg-white hover:shadow-md dark:border-gray-600/50 dark:bg-gray-800/80 dark:text-gray-200 dark:hover:bg-gray-800"
                    onclick={() => (showRulesModal = true)}
                    aria-label="View game rules"
                >
                    <Book size={20} />
                    <span class="hidden sm:inline">Rules</span>
                </button>
            </div>
        </div>

        <!-- Environment Detection Banner -->
        <EnvironmentBanner />

        <!-- Main unified content pane -->
        <div
            class="bg-surface-100-900/25 relative overflow-hidden rounded-2xl p-8 shadow-xl backdrop-blur-sm dark:shadow-2xl"
        >
            <!-- Subtle background pattern -->
            <div
                class="absolute inset-0 opacity-[0.03] dark:opacity-[0.05]"
                style="background-image: radial-gradient(circle at 1px 1px, currentColor 1px, transparent 0); background-size: 20px 20px;"
            ></div>

            <!-- Hero section -->
            <div class="relative mb-8 text-center">
                <h2 class="mb-3 text-3xl font-bold text-gray-900 dark:text-gray-100">
                    Ready to Roll?
                </h2>
                <p class="mx-auto max-w-2xl text-lg text-gray-700 dark:text-gray-400">
                    Roll six dice to score points. First to 10,000, or highest score wins!
                </p>
            </div>

            <!-- Game Action Buttons -->
            <div class="mb-10 flex flex-col gap-4 sm:flex-row sm:gap-6">
                <button
                    type="button"
                    class="group relative flex-1 overflow-hidden rounded-xl bg-gradient-to-r from-orange-400 to-red-500 px-8 py-6 text-lg font-semibold text-white shadow-lg transition-all duration-300 ease-out hover:scale-[1.02] hover:from-orange-500 hover:to-red-600 hover:shadow-xl"
                    onclick={() => console.log('Host Game clicked')}
                >
                    <div
                        class="absolute inset-0 bg-gradient-to-r from-white/0 to-white/10 opacity-0 transition-opacity duration-300 group-hover:opacity-100"
                    ></div>
                    <span class="relative flex items-center justify-center gap-3">
                        <span class="text-2xl">🎲</span>
                        Host Game
                    </span>
                </button>

                <button
                    type="button"
                    class="group relative flex-1 overflow-hidden rounded-xl border-2 border-teal-300/50 bg-teal-50/50 px-8 py-6 text-lg font-semibold text-teal-700 backdrop-blur-sm transition-all duration-300 ease-out hover:scale-[1.02] hover:border-teal-400/50 hover:bg-teal-100/80 hover:shadow-lg dark:border-teal-600/50 dark:bg-teal-900/30 dark:text-teal-200 dark:hover:border-teal-500/50 dark:hover:bg-teal-800/50"
                    onclick={() => console.log('Join Game clicked')}
                >
                    <span class="relative flex items-center justify-center gap-3">
                        <span class="text-2xl">👥</span>
                        Join Game
                    </span>
                </button>
            </div>

            <!-- Stats and Tips in flowing layout -->
            <div class="grid gap-8 lg:grid-cols-2">
                <!-- Player Stats Section -->
                <div class="space-y-4">
                    <h3
                        class="flex items-center gap-2 text-xl font-semibold text-gray-900 dark:text-gray-100"
                    >
                        <div
                            class="h-1 w-8 rounded-full bg-gradient-to-r from-orange-400 to-red-500"
                        ></div>
                        Your Stats
                    </h3>
                    <div class="space-y-3">
                        <PlayerStats />
                    </div>
                </div>

                <!-- Game Tips Section -->
                <div class="space-y-4">
                    <h3
                        class="flex items-center gap-2 text-xl font-semibold text-gray-900 dark:text-gray-100"
                    >
                        <div
                            class="h-1 w-8 rounded-full bg-gradient-to-r from-teal-400 to-cyan-500"
                        ></div>
                        Quick Tips
                    </h3>
                    <div class="space-y-3">
                        <GameTips />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Chain Status Banner -->
<ChainStatusBanner />

<!-- Rules Modal -->
<Modal bind:open={showRulesModal} title="Farkle Rules">
    <div class="space-y-6">
        <!-- YouTube Video Embed -->
        <div class="aspect-video w-full overflow-hidden rounded-lg">
            <iframe
                src="https://www.youtube.com/embed/EvWcUDYB9wQ"
                title="How to Play Farkle"
                class="h-full w-full"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen
            ></iframe>
        </div>

        <p class="text-lg text-gray-700 dark:text-gray-300">
            Roll six dice to score points. First to 10,000, or highest score wins!
        </p>

        <div class="grid gap-6 md:grid-cols-2">
            <div>
                <h3 class="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">
                    How to Play
                </h3>
                <ul class="list-disc space-y-2 pl-5 text-gray-700 dark:text-gray-300">
                    <li>Roll all six dice</li>
                    <li>Set aside scoring dice</li>
                    <li>Roll remaining dice or bank points</li>
                    <li>No scoring dice = "Farkle" (lose turn points)</li>
                    <li>Score all six dice = roll again</li>
                    <li>
                        After a player reaches 10,000 points, other players have one last turn to
                        try to surpass their score
                    </li>
                </ul>
            </div>

            <div>
                <h3 class="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">Scoring</h3>
                <ul class="list-disc space-y-1 pl-5 text-sm text-gray-700 dark:text-gray-300">
                    <li>Single 1 = 100 points</li>
                    <li>Single 5 = 50 points</li>
                    <li>Three 1s = 1,000 points</li>
                    <li>Three of a kind (2-6) = 100 × number</li>
                    <li>Four of a kind = 1,000 points</li>
                    <li>Five of a kind = 2,000 points</li>
                    <li>Six of a kind = 3,000 points</li>
                    <li>Straight (1-6) = 1,500 points</li>
                    <li>Three pairs = 1,500 points</li>
                    <li>Four of a kind + pair = 1,500 points</li>
                    <li>Two three of a kinds = 2,500 points</li>
                </ul>
            </div>
        </div>
    </div>
</Modal>
