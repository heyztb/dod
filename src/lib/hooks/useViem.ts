import { getContext } from 'svelte';
import { derived } from 'svelte/store';

export function useViem() {
	const store = getContext<typeof import('$lib/stores/viem').viemStore>('viem');

	if (!store) {
		throw new Error('useViem must be used within a ViemProvider');
	}

	return store;
}

export function usePublicClient() {
	const viem = useViem();
	return derived([viem], ([$viem]) => $viem.publicClient);
}

export function useWalletClient() {
	const viem = useViem();
	return derived([viem], ([$viem]) => $viem.walletClient);
}

export function useAccount() {
	const viem = useViem();
	return derived([viem], ([$viem]) => ({
		address: $viem.address,
		isConnected: $viem.isConnected,
		chainId: $viem.chainId
	}));
}

export function useChain() {
	const viem = useViem();
	return derived([viem], ([$viem]) => $viem.chainId);
}

export function useSwitchChain() {
	const viem = useViem();
	return viem.switchChain;
}

export function useViemState() {
	const viem = useViem();
	return derived([viem], ([$viem]) => $viem);
}
