<script lang="ts">
	import { page } from '$app/state';
	import { Home, Gamepad2, Trophy } from 'lucide-svelte';

	// Navigation items configuration
	const navItems = [
		{
			href: '/',
			icon: Home,
			label: 'Lobby',
			ariaLabel: 'Go to lobby'
		},
		{
			href: '/game',
			icon: Gamepad2,
			label: 'Game',
			ariaLabel: 'Go to game'
		},
		{
			href: '/leaderboard',
			icon: Trophy,
			label: 'Leaderboard',
			ariaLabel: 'View leaderboard'
		}
	];

	// Enhanced active state detection
	const isActive = (href: string) => {
		const currentPath = page.url.pathname;
		if (href === '/') {
			return currentPath === '/';
		}
		return currentPath.startsWith(href);
	};

	// Get appropriate classes for nav items
	const getNavItemClasses = (href: string) => {
		const baseClasses =
			'btn flex items-center gap-2 transition-all duration-200 ease-in-out relative';
		const activeClasses = 'preset-filled scale-105 shadow-lg';
		const inactiveClasses = 'hover:preset-tonal hover:scale-102 hover:shadow-md';

		return `${baseClasses} ${isActive(href) ? activeClasses : inactiveClasses}`;
	};

	// Keyboard navigation handler
	const handleKeydown = (event: KeyboardEvent, href: string) => {
		if (event.key === 'Enter' || event.key === ' ') {
			event.preventDefault();
			window.location.href = href;
		}
	};

	// Add haptic feedback for mobile devices
	const handleClick = () => {
		if ('vibrate' in navigator) {
			navigator.vibrate(50);
		}
	};

	// Preload pages on hover for better performance
	const handleMouseEnter = (href: string) => {
		if (typeof window !== 'undefined') {
			const link = document.createElement('link');
			link.rel = 'prefetch';
			link.href = href;
			document.head.appendChild(link);
		}
	};
</script>

<nav
	class="btn-group preset-outlined-neutral-200-800 bg-surface-50/90 dark:bg-surface-900/90 border-surface-200 dark:border-surface-700 safe-area-inset-bottom fixed right-0 bottom-0 left-0 z-50 flex flex-row justify-between border-t px-4 py-4 pb-8 shadow-2xl backdrop-blur-md"
	style="padding-bottom: max(2rem, env(safe-area-inset-bottom, 2rem));"
	aria-label="Main navigation"
>
	{#each navItems as { href, icon: Icon, label, ariaLabel }, index}
		<a
			{href}
			class="max-w-[140px] flex-1"
			aria-label={ariaLabel}
			onmouseenter={() => handleMouseEnter(href)}
		>
			<button
				type="button"
				class={getNavItemClasses(href)}
				onclick={handleClick}
				onkeydown={(e) => handleKeydown(e, href)}
				aria-current={isActive(href) ? 'page' : undefined}
				tabindex={index}
				style="min-height: 48px; padding: 0.75rem;"
			>
				<!-- Icon with enhanced styling -->
				<div class="relative">
					<Icon
						size={22}
						class="transition-transform duration-200 {isActive(href)
							? 'scale-110'
							: 'group-hover:scale-105'}"
						aria-hidden="true"
					/>
				</div>

				<!-- Label with responsive visibility -->
				<span class="hidden text-sm font-medium transition-opacity duration-200 sm:inline">
					{label}
				</span>

				<!-- Mobile-only label that appears on active -->
				<span class="text-xs font-medium sm:hidden">
					{label}
				</span>
			</button>
		</a>
	{/each}

	<!-- Visual enhancement: gradient overlay -->
	<div
		class="to-surface-50/20 dark:to-surface-900/20 pointer-events-none absolute inset-0 rounded-t-lg bg-gradient-to-t from-transparent via-transparent"
		aria-hidden="true"
	></div>
</nav>

<!-- Add some bottom padding to prevent content from being hidden behind the nav -->
<div class="h-28" aria-hidden="true"></div>

<style>
	/* Enhanced hover effects */
	.btn:hover {
		transform: translateY(-1px);
	}

	.btn:active {
		transform: translateY(0);
	}

	/* Smooth focus ring */
	.btn:focus-visible {
		outline: 2px solid rgb(var(--color-primary-500));
		outline-offset: 2px;
	}

	/* Custom scale utilities for subtle animations */
	.scale-102 {
		transform: scale(1.02);
	}

	/* Ensure proper stacking */
	nav {
		backdrop-filter: blur(12px);
		-webkit-backdrop-filter: blur(12px);
	}
</style>
