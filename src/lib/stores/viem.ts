import { writable, derived } from 'svelte/store';
import {
    createPublicClient,
    createWalletClient,
    type PublicClient,
    type WalletClient,
    type Chain,
    type Address
} from 'viem';
import { base, baseSepolia } from 'viem/chains';
import { farcasterTransport } from '$lib/viem/transport.js';

import sdk from '@farcaster/frame-sdk';

export interface ViemState {
    publicClient: PublicClient | null;
    walletClient: WalletClient | null;
    address: Address | null;
    chainId: number | null;
    isConnected: boolean;
    isConnecting: boolean;
    error: string | null;
}

function createViemStore() {
    const initialState: ViemState = {
        publicClient: null,
        walletClient: null,
        address: null,
        chainId: null,
        isConnected: false,
        isConnecting: false,
        error: null
    };

    const { subscribe, update } = writable(initialState);

    return {
        subscribe,

        async initialize() {
            if (!sdk.wallet?.ethProvider) {
                update((state) => ({
                    ...state,
                    error: 'Farcaster ethereum provider not available'
                }));
                return;
            }

            try {
                update((state) => ({ ...state, isConnecting: true, error: null }));

                // Get current account and chain
                const accounts = (await sdk.wallet.ethProvider.request({
                    method: 'eth_accounts'
                })) as Address[];

                const chainId = (await sdk.wallet.ethProvider.request({
                    method: 'eth_chainId'
                })) as string;

                const currentChainId = parseInt(chainId, 16);
                let chainConfig: Chain;
                switch (currentChainId) {
                    case base.id:
                        chainConfig = base;
                        break;
                    case baseSepolia.id:
                        chainConfig = baseSepolia;
                        break;
                    default:
                        chainConfig = baseSepolia;
                }

                // Create clients with farcaster transport
                const transport = farcasterTransport();

                const publicClient = createPublicClient({
                    chain: chainConfig, // Default to baseSepolia
                    transport
                }) as PublicClient;

                const walletClient = createWalletClient({
                    account: accounts[0],
                    chain: chainConfig,
                    transport
                }) as WalletClient;

                update((state) => ({
                    ...state,
                    publicClient,
                    walletClient,
                    address: accounts[0] || null,
                    chainId: parseInt(chainId, 16),
                    isConnected: accounts.length > 0,
                    isConnecting: false
                }));
            } catch (error) {
                update((state) => ({
                    ...state,
                    isConnecting: false,
                    error: error instanceof Error ? error.message : 'Failed to initialize'
                }));
            }
        },

        async switchChain(targetChain: Chain) {
            if (!sdk.wallet?.ethProvider) return;

            try {
                await sdk.wallet.ethProvider.request({
                    method: 'wallet_switchEthereumChain',
                    params: [{ chainId: `0x${targetChain.id.toString(16)}` }]
                });

                // Get current account and chain
                const accounts = (await sdk.wallet.ethProvider.request({
                    method: 'eth_accounts'
                })) as Address[];

                // Update clients with new chain
                const transport = farcasterTransport();
                const publicClient = createPublicClient({
                    chain: targetChain,
                    transport
                }) as PublicClient;

                const walletClient = createWalletClient({
                    account: accounts[0],
                    chain: targetChain,
                    transport
                }) as WalletClient;

                update((state) => ({
                    ...state,
                    publicClient,
                    walletClient,
                    chainId: targetChain.id
                }));
            } catch (error) {
                update((state) => ({
                    ...state,
                    error: error instanceof Error ? error.message : 'Failed to switch chain'
                }));
            }
        }
    };
}

export const viemStore = createViemStore();

// Derived stores for convenience
export const publicClient = derived([viemStore], ([$viem]) => $viem.publicClient);
export const walletClient = derived([viemStore], ([$viem]) => $viem.walletClient);
export const address = derived([viemStore], ([$viem]) => $viem.address);
export const chainId = derived([viemStore], ([$viem]) => $viem.chainId);
export const isConnected = derived([viemStore], ([$viem]) => $viem.isConnected);
