import { writable } from 'svelte/store';
import { sdk } from '@farcaster/frame-sdk';
import adze from 'adze';
import type { Context } from '@farcaster/frame-sdk';

const logger = adze.ns('frontend', 'environment');

interface EnvironmentState {
	isInMiniApp: boolean;
	isDetecting: boolean;
	hasDetected: boolean;
	context: Context.FrameContext | null;
	error?: string;
}

const initialState: EnvironmentState = {
	isInMiniApp: false,
	isDetecting: false,
	hasDetected: false,
	context: null
};

export const environmentStore = writable<EnvironmentState>(initialState);

class EnvironmentService {
	private detectPromise: Promise<boolean> | null = null;

	async detect(): Promise<boolean> {
		// Avoid multiple detection attempts
		if (this.detectPromise) {
			return this.detectPromise;
		}

		this.detectPromise = this.performDetection();
		return this.detectPromise;
	}

	private async performDetection(): Promise<boolean> {
		environmentStore.update((state) => ({
			...state,
			isDetecting: true,
			error: undefined
		}));

		try {
			logger.debug('Starting environment detection');

			// Use the SDK's built-in detection
			const isInMiniApp = await sdk.isInMiniApp();

			logger.info('Environment detected', { isInMiniApp });

			let context = null;
			if (isInMiniApp) {
				try {
					// Only get context if we're in a MiniApp
					await sdk.actions.ready({ disableNativeGestures: true });
					context = await sdk.context;
					logger.debug('MiniApp context obtained', {
						hasUser: !!context?.user,
						clientAdded: context?.client?.added
					});
				} catch (contextError) {
					logger.warn('Failed to get MiniApp context', {
						error: contextError instanceof Error ? contextError.message : 'Unknown error'
					});
				}
			}

			environmentStore.update((state) => ({
				...state,
				isInMiniApp,
				context,
				isDetecting: false,
				hasDetected: true
			}));

			return isInMiniApp;
		} catch (error) {
			logger.error('Environment detection failed', {
				error: error instanceof Error ? error.message : 'Unknown error',
				stack: error instanceof Error ? error.stack : undefined
			});

			// Assume standalone web on detection failure
			environmentStore.update((state) => ({
				...state,
				isInMiniApp: false,
				isDetecting: false,
				hasDetected: true,
				error: error instanceof Error ? error.message : 'Detection failed'
			}));

			return false;
		}
	}

	async ensureInitialized(): Promise<EnvironmentState> {
		const currentState = await new Promise<EnvironmentState>((resolve) => {
			const unsubscribe = environmentStore.subscribe((state) => {
				if (state.hasDetected || state.error) {
					unsubscribe();
					resolve(state);
				}
			});
		});

		if (!currentState.hasDetected && !currentState.isDetecting) {
			await this.detect();
			return new Promise<EnvironmentState>((resolve) => {
				const unsubscribe = environmentStore.subscribe((state) => {
					if (state.hasDetected || state.error) {
						unsubscribe();
						resolve(state);
					}
				});
			});
		}

		return currentState;
	}
}

export const environmentService = new EnvironmentService();

// Derived store for easy access to detection state
export const isInMiniApp = {
	subscribe: (callback: (value: boolean) => void) => {
		return environmentStore.subscribe((state) => callback(state.isInMiniApp));
	}
};

export const miniAppContext = {
	subscribe: (callback: (value: Context.FrameContext | null) => void) => {
		return environmentStore.subscribe((state) => callback(state.context));
	}
};

// Auto-detect on store creation (client-side only)
if (typeof window !== 'undefined') {
	environmentService.detect();
}
