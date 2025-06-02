import { createTransport, type Transport } from 'viem';
import sdk from '@farcaster/frame-sdk';

export interface FarcasterTransportConfig {
	name?: string;
}

export function farcasterTransport(config: FarcasterTransportConfig = {}): Transport {
	return ({ retryCount: defaultRetryCount, timeout: defaultTimeout }) =>
		createTransport({
			key: 'farcaster',
			name: config.name ?? 'Farcaster Transport',
			async request({ method, params }): Promise<any> {
				if (!sdk.wallet?.ethProvider) {
					throw new Error('Farcaster ethereum provider not available');
				}

				// The Farcaster SDK provides an EIP-1193 compatible provider
				const provider = sdk.wallet.ethProvider;

				try {
					const result = await provider.request({
						method,
						params: params as any[]
					});
					return result;
				} catch (error) {
					// Handle specific ethereum errors
					if (error instanceof Error) {
						throw error;
					}
					throw new Error(`Transport request failed: ${error}`);
				}
			},
			retryCount: defaultRetryCount,
			timeout: defaultTimeout,
			type: 'farcaster'
		});
}
