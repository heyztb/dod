# Viem Integration for Farcaster Mini Apps

This document describes the custom viem integration built for the Dice of Destiny Farcaster Mini App application, providing a clean, type-safe Web3 interface using the Farcaster SDK's EIP-1193 provider.

## Overview

Instead of using wagmi (which can be heavy for Mini App applications), we built a lightweight viem-based solution that:

- Uses Farcaster SDK's built-in ethereum provider (`sdk.wallet.ethProvider`)
- Provides a React-like hooks API similar to wagmi
- Leverages Svelte's context system for state management
- Offers full TypeScript support with viem's excellent type safety
- Automatically handles account and chain changes

## Architecture

### Core Components

1. **Custom Viem Transport** (`src/lib/viem/transport.ts`)

   - Bridges Farcaster SDK's EIP-1193 provider to viem
   - Handles all RPC requests through the Mini App's wallet provider

2. **Viem Store** (`src/lib/stores/viem.ts`)

   - Manages wallet state (address, chain, connection status)
   - Creates and maintains viem public/wallet clients
   - Handles chain switching and initialization

3. **Provider Component** (`src/lib/providers/ViemProvider.svelte`)

   - Sets up context for the viem store
   - Listens for account/chain changes from Farcaster provider
   - Initializes when Mini App context becomes available

4. **React-like Hooks** (`src/lib/hooks/useViem.ts`)

   - `useAccount()` - Get wallet address, connection status, chain ID
   - `usePublicClient()` - Access viem public client for reading blockchain
   - `useWalletClient()` - Access viem wallet client for transactions
   - `useSwitchChain()` - Switch between supported chains
   - `useViemState()` - Access full viem state

5. **App Provider** (`src/lib/providers/AppProvider.svelte`)
   - Composes FrameProvider and ViemProvider
   - Single provider for the entire app

## Usage

### Setup

Update your layout to use the AppProvider:

```svelte
<script lang="ts">
	import AppProvider from '$lib/providers/AppProvider.svelte';
</script>

<AppProvider>
	{#snippet children()}
		<slot />
	{/snippet}
</AppProvider>
```

### Using in Components

```svelte
<script lang="ts">
	import { useAccount, usePublicClient, useSwitchChain } from '$lib/hooks/useViem.js';
	import { formatEther } from 'viem';
	import { base, baseSepolia } from 'viem/chains';

	const account = useAccount();
	const publicClient = usePublicClient();
	const switchChain = useSwitchChain();

	let balance = $state<string | null>(null);

	// Get balance when account changes
	$effect(() => {
		const loadBalance = async () => {
			if ($account.address && $publicClient && $account.isConnected) {
				try {
					const bal = await $publicClient.getBalance({
						address: $account.address
					});
					balance = formatEther(bal);
				} catch (error) {
					console.error('Failed to get balance:', error);
				}
			}
		};

		loadBalance();
	});

	async function handleSwitchChain() {
		try {
			await switchChain(baseSepolia);
		} catch (error) {
			console.error('Failed to switch chain:', error);
		}
	}
</script>

<div>
	{#if $account.isConnected}
		<p>Address: {$account.address}</p>
		<p>Chain: {$account.chainId}</p>
		{#if balance}
			<p>Balance: {balance} ETH</p>
		{/if}

		<button onclick={handleSwitchChain}> Switch to Base Sepolia </button>
	{:else}
		<p>Wallet not connected</p>
	{/if}
</div>
```

### Making Transactions

```svelte
<script lang="ts">
	import { useWalletClient, useAccount } from '$lib/hooks/useViem.js';
	import { parseEther } from 'viem';

	const walletClient = useWalletClient();
	const account = useAccount();

	async function sendTransaction() {
		if (!$walletClient || !$account.address) return;

		try {
			const hash = await $walletClient.sendTransaction({
				to: '0x742d35Cc7cFb4e93c59f2F85e0B52B5d7D46EE1e',
				value: parseEther('0.01')
			});

			console.log('Transaction sent:', hash);
		} catch (error) {
			console.error('Transaction failed:', error);
		}
	}
</script>

<button onclick={sendTransaction} disabled={!$account.isConnected}> Send 0.01 ETH </button>
```

### Reading Contract Data

```svelte
<script lang="ts">
	import { usePublicClient } from '$lib/hooks/useViem.js';

	const publicClient = usePublicClient();

	let tokenBalance = $state<bigint | null>(null);

	$effect(async () => {
		if ($publicClient) {
			try {
				// Read from an ERC20 contract
				const balance = await $publicClient.readContract({
					address: '0x...',
					abi: [
						{
							inputs: [{ name: 'owner', type: 'address' }],
							name: 'balanceOf',
							outputs: [{ name: '', type: 'uint256' }],
							stateMutability: 'view',
							type: 'function'
						}
					],
					functionName: 'balanceOf',
					args: ['0x...']
				});

				tokenBalance = balance;
			} catch (error) {
				console.error('Failed to read contract:', error);
			}
		}
	});
</script>
```

## API Reference

### Hooks

#### `useAccount()`

Returns reactive store with wallet account information.

```typescript
interface AccountState {
	address: Address | null;
	isConnected: boolean;
	chainId: number | null;
}
```

#### `usePublicClient()`

Returns reactive store with viem public client for reading blockchain data.

#### `useWalletClient()`

Returns reactive store with viem wallet client for sending transactions.

#### `useSwitchChain()`

Returns function to switch chains.

```typescript
function switchChain(targetChain: Chain): Promise<void>;
```

#### `useViemState()`

Returns reactive store with full viem state including loading states and errors.

```typescript
interface ViemState {
	publicClient: PublicClient | null;
	walletClient: WalletClient | null;
	address: Address | null;
	chainId: number | null;
	isConnected: boolean;
	isConnecting: boolean;
	error: string | null;
}
```

### Supported Chains

Currently configured for:

- Base Mainnet (chainId: 8453)
- Base Sepolia (chainId: 84532)

To add more chains, update the import in `src/lib/stores/viem.ts` and `src/lib/ui/WalletInfo.svelte`.

## Error Handling

The system handles various error states:

- **Provider Not Available**: When Farcaster ethereum provider isn't ready
- **Connection Errors**: When wallet requests fail
- **Chain Switch Errors**: When user rejects chain switch requests
- **Transaction Errors**: Standard viem/ethereum transaction errors

All errors are surfaced through the `useViemState()` hook's error property.

## Advantages Over Wagmi

1. **Lighter Weight**: No React Query dependency, smaller bundle size
2. **Mini App-Specific**: Built specifically for Farcaster Mini App constraints
3. **Svelte Native**: Uses Svelte's reactivity system instead of React patterns
4. **Direct Integration**: Uses Farcaster SDK's provider directly
5. **Type Safety**: Full viem TypeScript support

## Troubleshooting

### Common Issues

**Provider Not Available Error**

- Ensure FrameProvider is properly initialized before ViemProvider
- Check that Farcaster SDK context is available

**Chain Switch Failures**

- User may have rejected the request
- Target chain may not be supported by the wallet
- Check error messages for specific details

**Transaction Failures**

- Ensure wallet is connected and on the correct chain
- Check gas estimation and user balance
- Verify contract addresses and ABIs

### Debug Mode

Enable debug logging by accessing `useViemState()` and logging the full state:

```svelte
<script lang="ts">
	import { useViemState } from '$lib/hooks/useViem.js';

	const viemState = useViemState();

	$effect(() => {
		console.log('Viem State:', $viemState);
	});
</script>
```

## Examples

See `src/lib/ui/WalletInfo.svelte` for a complete example showing:

- Wallet connection status
- Balance fetching
- Chain switching
- Error handling
- Loading states

This component can be used as a reference for implementing your own Web3 features.
