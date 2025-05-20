<script lang="ts">
	import '../app.css';
	let { children } = $props();
	const frameEmbedData = {
		version: 'next',
		imageUrl: 'https://dod.ztb.dev/favicon.png',
		button: {
			title: '🎲 Play Dice of Destiny',
			action: {
				type: 'launch_frame',
				url: 'https://dod.ztb.dev',
				name: 'Dice of Destiny',
				splashImageUrl: 'https://dod.ztb.dev/favicon.png',
				splashBackgroundColor: '#f5f0ec'
			}
		}
	};
</script>

<svelte:head>
	<title>Dice of Destiny</title>
	<meta name="description" content="Dice of Destiny is a social dice game on Farcaster." />
	<meta name="robots" content="index, follow" />
	<meta property="og:title" content="Dice of Destiny" />
	<meta property="og:description" content="Dice of Destiny is a social dice game on Farcaster." />
	<meta property="og:image" content="https://dod.ztb.dev/og-image.png" />
	<meta property="og:url" content="https://dod.ztb.dev" />
	<meta property="og:type" content="website" />
	<meta property="og:site_name" content="Dice of Destiny" />
	<meta property="og:locale" content="en_US" />
	<meta property="fc:frame" content={JSON.stringify(frameEmbedData)} />
</svelte:head>

{@render children()}
