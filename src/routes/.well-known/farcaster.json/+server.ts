import type { RequestHandler } from '@sveltejs/kit';

type MiniAppManifest = {
	accountAssociation?: {
		header: string;
		payload: string;
		signature: string;
	};
	frame: {
		version: '1'; // String literal '1' since it must be exactly '1'
		name: string; // Mini App name
		homeUrl: string; // Default launch URL
		iconUrl: string; // Icon image URL

		imageUrl?: string; // [DEPRECATED] Default image for feed sharing
		buttonTitle?: string; // [DEPRECATED] Default button title for feed
		splashImageUrl?: string; // URL of loading screen image
		splashBackgroundColor?: string; // Hex color code for loading screen
		webhookUrl?: string; // URL for event POSTs
		subtitle?: string; // Short description under app name
		description?: string; // Promotional message
		screenshotUrls?: string[]; // Array of screenshot URLs
		primaryCategory?:
			| 'games'
			| 'social'
			| 'finance'
			| 'utility'
			| 'productivity'
			| 'health-fitness'
			| 'news-media'
			| 'music'
			| 'shopping'
			| 'education'
			| 'developer-tools'
			| 'entertainment'
			| 'art-creativity';
		// Union of allowed category values
		tags?: string[]; // Array of descriptive tags
		heroImageUrl?: string; // Promotional display image URL
		tagline?: string; // Marketing tagline
		ogTitle?: string; // Open Graph title
		ogDescription?: string; // Open Graph description
		ogImageUrl?: string; // Open Graph image URL
		noindex?: boolean; // Whether to exclude from search results
		requiredChains?: string[]; // Array of required chains
		requriedCapabilities?: string[]; // Array of required capabilities
	};
};

const manifest: MiniAppManifest = {
	accountAssociation: {
		header:
			'eyJmaWQiOjk3OTI4NCwidHlwZSI6ImN1c3RvZHkiLCJrZXkiOiIweGEzRmYxMTE3Njc2RkM3RjVkMUQ4YkExNzUxN0JGM2FkOGFhOTRFMTEifQ',
		payload: 'eyJkb21haW4iOiJkb2QuenRiLmRldiJ9',
		signature:
			'MHhkZjQwOTJhZjJlMmY0MTkzNDRmOTc0MDQwZjM0OGQ0MDQ1NzM0MmIyNTVhMDQ2MTcwOGVjYWYzZjhmMGFjMGM1NTI2MjMwYjE2ZDJjMTU0ZTg1OWExMTY2NmIwMTQxNjNiNWIyMmU1YjJhNWZkNDczMTc4NGRlNTM4ZWMyMmIwMTFj'
	},
	frame: {
		version: '1',
		name: 'Dice of Destiny',
		description:
			'A social dice game on Farcaster. Farkle is a game of strategy and chance. Roll the dice and realize your fate.',
		subtitle: 'Social dice game on Farcaster',
		homeUrl: 'https://dod.ztb.dev',
		iconUrl: 'https://dod.ztb.dev/favicon.png',
		primaryCategory: 'games',
		tags: ['multiplayer', 'game', 'strategy', 'chance', 'social'],
		splashBackgroundColor: '#ffffff',
		splashImageUrl: 'https://dod.ztb.dev/favicon.png',
		tagline: 'Realize your fate',
		ogTitle: 'Dice of Destiny',
		ogDescription:
			'A social dice game on Farcaster. Farkle is a game of strategy and chance. Realize your fate today.',
		ogImageUrl: 'https://dod.ztb.dev/favicon.png',
		noindex: false,
		requiredChains: ['eip155:8453', 'eip155:84532'],
		requriedCapabilities: ['wallet.getEthereumProvider']
	}
};

export const GET: RequestHandler = async () => {
	return new Response(JSON.stringify(manifest), {
		headers: {
			'Content-Type': 'application/json'
		}
	});
};
