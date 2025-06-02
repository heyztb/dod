import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

// place files you want to import through the `$lib` alias in this folder.
export const getDomainFromUrl = (url: string) => {
	const parsedUrl = new URL(url);
	return parsedUrl.hostname;
};

export const cn = (...classes: ClassValue[]) => {
	return twMerge(clsx(classes));
};

// Viem hooks
export {
	useViem,
	usePublicClient,
	useWalletClient,
	useAccount,
	useChain,
	useSwitchChain,
	useViemState
} from './hooks/useViem.js';

// Viem stores
export {
	viemStore,
	publicClient,
	walletClient,
	address,
	chainId,
	isConnected
} from './stores/viem.js';

// Providers
export { default as AppProvider } from './providers/AppProvider.svelte';
export { default as ViemProvider } from './providers/ViemProvider.svelte';
export { default as FrameProvider } from './providers/FrameProvider.svelte';

// Viem transport
export { farcasterTransport } from './viem/transport.js';
