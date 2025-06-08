# Farkle Onchain - Project Specification

## 🎯 **Project Vision**

Create the gold standard for onchain gaming UX - a fully decentralized Farkle implementation that feels as smooth as Web2 while leveraging blockchain for transparency, provable fairness, and economic incentives.

## 🔥 **Core Principles**

1. **Onchain First**: Game logic, randomness, and state live on blockchain
2. **Invisible Complexity**: Users never feel like they're using crypto
3. **Instant Feedback**: No waiting for blockchain - optimistic UI updates
4. **Provably Fair**: All randomness and game logic verifiable onchain
5. **MiniApp Native**: Optimized for Farcaster MiniApp experience with potential web expansion

---

## 🏗️ **Technical Architecture**

### **Smart Contract Design**

```solidity
// Core contracts needed:
FarkleGame.sol       // Main game logic and state
FarkleRandomness.sol // VRF-based dice rolling
FarkleRooms.sol      // Game room management
FarkleTournaments.sol // Tournament brackets
FarkleRewards.sol    // Prize pools and payouts
```

### **Onchain Game State**

```typescript
interface GameState {
	gameId: bigint;
	players: [Player, Player]; // 2-player focus initially
	currentPlayer: 0 | 1;
	currentTurn: {
		dice: [number, number, number, number, number, number];
		selectedDice: boolean[];
		turnScore: number;
		rollsRemaining: number;
	};
	scores: [number, number];
	gameStatus: 'waiting' | 'active' | 'finished';
	winner?: 0 | 1;
	randomSeed: bigint; // For verifiable randomness
}
```

### **Hybrid State Management**

- **Onchain**: Authoritative game state, final dice rolls, scores
- **Offchain**: UI state, animations, optimistic updates
- **Sync Strategy**: Optimistic updates with rollback on chain mismatch

---

## 🎮 **Game Mechanics (Onchain)**

### **Dice Rolling System**

```solidity
// Chainlink VRF for provably fair randomness
function rollDice(uint256 gameId, uint8 numDice) external {
    require(games[gameId].currentPlayer == msg.sender);
    requestRandomness(gameId, numDice);
}

// Callback processes dice results
function fulfillRandomness(uint256 gameId, uint256 randomness) internal {
    uint8[] memory dice = generateDice(randomness, numDice);
    games[gameId].currentTurn.dice = dice;
    emit DiceRolled(gameId, dice);
}
```

### **Scoring Engine (Onchain)**

```solidity
function calculateScore(uint8[] memory dice, bool[] memory selected)
    public pure returns (uint256 score, bool hasScoringDice) {
    // All Farkle scoring logic implemented onchain
    // - Singles (1s = 100, 5s = 50)
    // - Three-of-a-kind, four-of-a-kind, etc.
    // - Straights, three pairs, etc.
}
```

### **Turn Management**

```solidity
function selectDice(uint256 gameId, bool[] memory selection) external {
    GameState storage game = games[gameId];
    require(game.currentPlayer == getPlayerIndex(msg.sender));

    (uint256 score, bool hasScoring) = calculateScore(game.currentTurn.dice, selection);
    require(hasScoring, "No scoring dice selected");

    game.currentTurn.selectedDice = selection;
    game.currentTurn.turnScore += score;

    emit DiceSelected(gameId, selection, score);
}
```

---

## 🎨 **UX Design Philosophy**

### **"Invisible Blockchain" Principles**

1. **Instant Response**: UI updates immediately, blockchain confirms later
2. **Smart Defaults**: Auto-select optimal dice, suggest best moves
3. **Progressive Disclosure**: Advanced features hidden until needed
4. **Contextual Help**: Inline tips, scoring helpers, probability indicators
5. **Error Recovery**: Graceful handling of failed transactions

### **User Flow Examples**

**🎲 Rolling Dice:**

```text
User clicks "Roll" → Dice animate immediately →
Smart contract called in background →
If mismatch, dice re-animate to correct values
```

**💰 Placing Bets:**

```text
User sees "Play for 0.001 ETH" →
Click → Wallet prompts →
Game starts immediately with "Confirming..." indicator →
Blockchain confirms in background
```

### **MiniApp First Design**

- **Native Integration**: Full-screen responsive web app within Farcaster
- **Touch Friendly**: Large tap targets, swipe gestures
- **Thumb Navigation**: Critical actions within thumb reach
- **Loading States**: Beautiful transitions during blockchain waits
- **Hybrid Architecture**: Works as standalone web app or Farcaster MiniApp

---

## 🔧 **Technical Implementation Plan**

### **Phase 1: Smart Contract Foundation (Weeks 1-2)**

```typescript
// Development priorities:
1. Deploy basic FarkleGame contract
2. Implement dice rolling with mock randomness
3. Build scoring engine with comprehensive tests
4. Create simple 2-player game flow
```

### **Phase 2: Frontend Integration (Weeks 3-4)**

```typescript
// Key components to build:
-DiceDisplay.svelte - // Animated dice with selection
	ScoreBoard.svelte - // Real-time score tracking
	TurnControls.svelte - // Roll/Bank/Select actions
	GameRoom.svelte - // Full game interface
	MiniAppDetector.svelte - // Environment detection & bootstrap
	OptimisticState.ts - // State management with rollback
	WalletProvider.svelte; // Hybrid wallet connection (MiniApp + web)
```

### **Phase 3: UX Polish (Weeks 5-6)**

```typescript
// UX enhancements:
- Dice rolling animations
- Score calculation hints
- Probability indicators
- Smart dice selection suggestions
- Responsive game states
```

### **Phase 4: Advanced Features (Weeks 7-8)**

```typescript
// Advanced functionality:
- Tournament brackets
- Spectator mode
- Game replays
- Leaderboards
- Prize pools
```

---

## 📱 **MiniApp Integration Strategy**

### **MiniApp Architecture**

```typescript
// farcaster.json manifest configuration
{
  "accountAssociation": { /* signed ownership proof */ },
  "frame": {
    "version": "1",
    "name": "Farkle Onchain",
    "iconUrl": "https://yourapp.com/icon.png",
    "homeUrl": "https://yourapp.com",
    "splashImageUrl": "https://yourapp.com/splash.png",
    "splashBackgroundColor": "#1a1a1a",
    "webhookUrl": "https://yourapp.com/api/webhook",
    "subtitle": "Provably fair onchain dice game",
    "description": "Roll dice, score points, win ETH in this fully onchain Farkle game",
    "primaryCategory": "games",
    "tags": ["games", "onchain", "dice", "farkle"],
    "requiredChains": ["eip155:8453"], // Base
    "requiredCapabilities": ["wallet.getEthereumProvider"]
  }
}
```

### **Environment Detection & Bootstrap**

```typescript
import { sdk } from '@farcaster/frame-sdk';

// Detect if running as MiniApp vs standalone web
const isMiniApp = await sdk.isInMiniApp();

if (isMiniApp) {
	// MiniApp-specific setup
	await sdk.actions.ready({ disableNativeGestures: true });
	const ethProvider = await sdk.wallet.getEthereumProvider();
	const chains = await sdk.wallet.getChains();
} else {
	// Standalone web app setup
	// Use regular wallet connection (WalletConnect, etc.)
}
```

### **MiniApp State Management**

```typescript
interface MiniAppState {
	gameId?: bigint;
	playerId: string;
	currentView: 'lobby' | 'game' | 'results';
	gameState?: GameState;
	pendingAction?: 'roll' | 'bank' | 'select';
	isInMiniApp: boolean;
	ethProvider?: any;
}
```

### **MiniApp-Specific Features**

```typescript
// Social integration within Farcaster
await sdk.actions.composeCast({
	text: 'Just won a game of Farkle! 🎲 Final score: 10,240 points',
	embeds: [`https://yourapp.com/game/${gameId}`]
});

// Quick authentication (no external wallet needed)
const { token } = await sdk.actions.quickAuth();

// Native wallet integration
const ethProvider = await sdk.wallet.getEthereumProvider();
const accounts = await ethProvider.request({ method: 'eth_accounts' });

// View profile integration
await sdk.actions.viewProfile({ fid: opponentFid });

// Add MiniApp to user's collection
await sdk.actions.addMiniApp();
```

### **Progressive Web App Enhancement**

```typescript
// Detect environment and provide appropriate UX
if (isMiniApp) {
	// Native Farcaster integration
	// Automatic wallet connection
	// Social features enabled
} else {
	// Standard web3 wallet connection
	// Share to Farcaster option
	// Manual onboarding flow
}
```

---

## 💎 **Economic Design**

### **Game Economics**

- **Entry Fees**: 0.001 - 0.01 ETH (Base/OP mainnet)
- **Winner Takes**: 90% of pot (10% to protocol)
- **Tournament**: Multi-tiered with increasing rewards
- **Spectator Betting**: Side bets on game outcomes

### **Token Integration**

```solidity
// Future: Custom game token
interface FarkleToken {
    function stakeTournament(uint256 amount) external;
    function claimRewards(uint256 gameId) external;
    function voteGovernance(uint256 proposal) external;
}
```

---

## 🚀 **Success Metrics**

### **UX Metrics**

- **Time to First Game**: < 30 seconds from landing
- **Transaction Success Rate**: > 95%
- **Game Completion Rate**: > 80%
- **User Retention**: > 40% return within 7 days

### **Technical Metrics**

- **Frame Load Time**: < 2 seconds
- **Blockchain Sync Accuracy**: 99.9%
- **Gas Optimization**: < $0.50 per full game
- **Uptime**: 99.5% availability

---

## 🛠️ **Development Stack**

### **Frontend**

- **SvelteKit 2** + **Svelte 5** (Runes)
- **Tailwind 4** (CSS-first config)
- **Viem** (Ethereum interactions)
- **@farcaster/frame-sdk** (MiniApp integration)
- **Hybrid routing** (MiniApp + standalone web detection)

### **Backend**

- **Cloudflare Workers** (MiniApp webhooks, API endpoints)
- **Supabase** (User data, leaderboards)
- **Onchain Events** (Primary data source)
- **MiniApp Manifest** (/.well-known/farcaster.json)

### **Blockchain**

- **Base** (Primary deployment)
- **Optimism** (Secondary)
- **Chainlink VRF** (Randomness)
- **Safe** (Multi-sig treasury)

---

## 🎯 **Immediate Next Steps**

### **Week 1 Sprint**

1. **Smart Contract**: Basic game logic + testing framework
2. **Frontend**: Game room UI with mock data
3. **Integration**: Connect wallet + contract interaction
4. **MiniApp**: Environment detection + manifest setup
5. **Hybrid Architecture**: Detect MiniApp vs standalone web

### **MVP Definition**

- ✅ 2-player Farkle game
- ✅ Onchain dice rolls + scoring
- ✅ Working Farcaster MiniApp
- ✅ Standalone web version
- ✅ Real ETH betting
- ✅ Mobile-optimized UX
- ✅ Hybrid wallet integration

This spec positions your project as the **gold standard for onchain gaming UX**. Ready to start building?
