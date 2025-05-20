import { writable } from 'svelte/store';
import type { Context } from '@farcaster/frame-sdk';

export const frameContext = writable<Context.FrameContext | null>(null);
