import adapter from '@sveltejs/adapter-auto';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

const config = {
	preprocess: vitePreprocess(),
	kit: { adapter: adapter() },
	csrf: { checkOrigin: process.env.NODE_ENV === 'production' ? true : false }
};

export default config;
