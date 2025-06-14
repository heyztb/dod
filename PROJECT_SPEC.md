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

### **Upgradeable Proxy Architecture**

**Beacon Proxy Architecture for Scalable Upgrades:**
- FarkleBeacon.sol - Central beacon for game logic upgrades
- FarkleGameBeacon.sol - Beacon specifically for game instances
- FarkleRoomsBeacon.sol - Beacon for room management
- FarkleTournamentsBeacon.sol - Beacon for tournament logic

**Proxy Factory Pattern:**
- FarkleProxyFactory.sol - Deploys new game instances via BeaconProxy
- FarkleRoomsFactory.sol - Deploys room instances
- FarkleTournamentFactory.sol - Deploys tournament brackets

**Core Implementation Contracts:**
- FarkleGameImpl.sol - Game logic implementation
- FarkleRandomnessImpl.sol - VRF-based dice rolling implementation  
- FarkleRoomsImpl.sol - Room management implementation
- FarkleTournamentsImpl.sol - Tournament bracket implementation
- FarkleRewardsImpl.sol - Prize pool and payout implementation

**Governance & Security:**
- FarkleGovernor.sol - Timelock governance for upgrades
- FarkleTimelock.sol - Timelock controller for upgrade delays
- FarkleUpgradeAuthority.sol - Role-based upgrade permissions

### **Beacon Proxy Benefits for Gaming**

**Why Beacon Proxy is Perfect for Farkle:**
- **Gas Efficiency**: Deploy games for ~50k gas vs 2M+ for full contracts
- **Coordinated Upgrades**: Upgrade all active games simultaneously
- **Feature Rollouts**: Deploy new features to all instances at once
- **Bug Fixes**: Critical fixes propagate to all games immediately
- **Economic Updates**: Adjust scoring/rewards across all games
- **Scalability**: Deploy 1000s of game instances cheaply

### **Smart Contract Architecture**

**Factory Contracts (Deploy New Instances):**
- FarkleGameFactory.sol - Creates new game instances via BeaconProxy
- FarkleRoomsFactory.sol - Creates room instances for different game modes
- FarkleTournamentFactory.sol - Creates tournament brackets

**Implementation Contracts (Upgradeable Logic):**
- FarkleGameImpl.sol - Core game logic and state management
- FarkleRandomnessImpl.sol - Chainlink VRF integration
- FarkleRoomsImpl.sol - Room management and matchmaking
- FarkleTournamentsImpl.sol - Tournament brackets and progression
- FarkleRewardsImpl.sol - Prize distribution and fee management
- FarkleGovernanceImpl.sol - Voting and upgrade proposals

**Beacon Contracts (Upgrade Coordination):**
- FarkleGameBeacon.sol - Points to current FarkleGameImpl
- FarkleRoomsBeacon.sol - Points to current FarkleRoomsImpl
- FarkleTournamentsBeacon.sol - Points to current FarkleTournamentsImpl
- FarkleRewardsBeacon.sol - Points to current FarkleRewardsImpl

**Governance & Security:**
- FarkleTimelock.sol - 48-hour delay on upgrades
- FarkleMultiSig.sol - Multi-signature upgrade authority
- FarkleEmergencyPause.sol - Circuit breaker for critical issues

### **Proxy Architecture Diagram**

```
┌─────────────────────────────────────────────────────────────────┐
│                    FARKLE PROXY ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  │   GOVERNANCE    │    │   TIMELOCK      │    │   MULTISIG      │
│  │   PROPOSALS     │◄──►│   CONTROLLER    │◄──►│   AUTHORITY     │
│  │                 │    │                 │    │                 │
│  └─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
│            │                      │                      │
│            └──────────────────────┼──────────────────────┘
│                                   │
│            ┌──────────────────────▼──────────────────────┐
│            │              UPGRADE AUTHORITY              │
│            │         (Controls all beacons)              │
│            └──────────────────────┬──────────────────────┘
│                                   │
│   ┌────────────────────────────────┼────────────────────────────────┐
│   │                               │                                │
│   ▼                               ▼                                ▼
│ ┌─────────────┐          ┌─────────────┐              ┌─────────────┐
│ │GAME BEACON  │          │ROOMS BEACON │              │TOURNEY      │
│ │             │          │Points to    │              │BEACON       │
│ │Points to    │          │RoomsImpl    │              │Points to    │
│ └──────┬──────┘          └──────┬──────┘              │TourneyImpl  │
│        │                        │                     └──────┬──────┘
│        │                        │                            │
│   ┌────▼────┐              ┌────▼────┐                  ┌────▼────┐
│   │GAME     │              │ROOMS    │                  │TOURNEY  │
│   │FACTORY  │              │FACTORY  │                  │FACTORY  │
│   │         │              │         │                  │         │
│   └────┬────┘              └────┬────┘                  └────┬────┘
│        │                        │                            │
│        │ Creates                │ Creates                    │ Creates
│        │ BeaconProxy            │ BeaconProxy                │ BeaconProxy
│        │                        │                            │
│   ┌────▼────┐              ┌────▼────┐                  ┌────▼────┐
│   │ GAME    │              │ ROOM    │                  │TOURNEY  │
│   │INSTANCE │              │INSTANCE │                  │INSTANCE │
│   │(Proxy)  │              │(Proxy)  │                  │(Proxy)  │
│   └─────────┘              └─────────┘                  └─────────┘
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                    IMPLEMENTATION LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│ │ GameImpl    │    │ RoomsImpl   │    │TourneyImpl  │          │
│ │ v1.0.0      │    │ v1.0.0      │    │ v1.0.0      │          │
│ │             │    │             │    │             │          │
│ │• rollDice() │    │• createRoom │    │• bracket()  │          │
│ │• selectDice │    │• joinRoom() │    │• advance()  │          │
│ │• bankTurn() │    │• gameReady()│    │• payout()   │          │
│ └─────────────┘    └─────────────┘    └─────────────┘          │
│                                                                 │
│└─────────────────────────────────────────────────────────────────┘
```

### **Onchain Game State**

**Updated interface with proxy-aware architecture:**
- gameId: bigint
- proxyAddress: string (Address of this game's proxy)
- implementationVersion: string (Track which impl version)
- players: [Player, Player]
- currentPlayer: 0 | 1
- currentTurn: dice, selectedDice, turnScore, rollsRemaining
- scores: [number, number]
- gameStatus: 'waiting' | 'active' | 'finished'
- winner?: 0 | 1
- randomSeed: bigint
- **Proxy-specific fields:**
  - upgradeable: boolean (Can this game be upgraded?)
  - pausable: boolean (Can this game be paused?)
  - lastUpgrade: bigint (Block number of last upgrade)

### **Hybrid State Management**

- **Onchain**: Authoritative game state, final dice rolls, scores
- **Offchain**: UI state, animations, optimistic updates
- **Sync Strategy**: Optimistic updates with rollback on chain mismatch

---

## 🎮 **Game Mechanics (Onchain)**

### **Dice Rolling System**
- Chainlink VRF for provably fair randomness
- Request randomness for specified number of dice
- Callback processes dice results and emits events

### **Scoring Engine (Onchain)**
- All Farkle scoring logic implemented onchain
- Singles (1s = 100, 5s = 50)
- Three-of-a-kind, four-of-a-kind, etc.
- Straights, three pairs, etc.

### **Turn Management**
- Validate player permissions and game state
- Calculate scores for selected dice
- Update turn state and emit events
- Handle win conditions and game progression

---

## 🎨 **UX Design Philosophy**

### **"Invisible Blockchain" Principles**

1. **Instant Response**: UI updates immediately, blockchain confirms later
2. **Smart Defaults**: Auto-select optimal dice, suggest best moves
3. **Progressive Disclosure**: Advanced features hidden until needed
4. **Contextual Help**: Inline tips, scoring helpers, probability indicators
5. **Error Recovery**: Graceful handling of failed transactions

### **User Flow Examples**

**Rolling Dice:**
User clicks "Roll" → Dice animate immediately → Smart contract called in background → If mismatch, dice re-animate to correct values

**Placing Bets:**
User sees "Play for 0.001 ETH" → Click → Wallet prompts → Game starts immediately with "Confirming..." indicator → Blockchain confirms in background

### **MiniApp First Design**

- **Native Integration**: Full-screen responsive web app within Farcaster
- **Touch Friendly**: Large tap targets, swipe gestures
- **Thumb Navigation**: Critical actions within thumb reach
- **Loading States**: Beautiful transitions during blockchain waits
- **Hybrid Architecture**: Works as standalone web app or Farcaster MiniApp

---

## 🔧 **Technical Implementation Plan**

### **Phase 1: Proxy Infrastructure (Weeks 1-2)**

**Updated development priorities:**
1. Deploy beacon proxy infrastructure
   - Create all beacon contracts
   - Deploy timelock governance
   - Set up multi-sig upgrade authority

2. Implement core game logic with proxy patterns
   - FarkleGameImpl with initializer pattern
   - Factory contract for game deployment
   - Comprehensive upgrade testing

3. Build comprehensive test suite
   - Proxy upgrade scenarios
   - State preservation across upgrades
   - Factory deployment patterns
   - Governance workflow testing

4. Security auditing preparation
   - Document upgrade paths
   - Role-based access controls
   - Emergency pause mechanisms

### **Phase 1.5: Upgrade Governance (Week 2.5)**

**Governance implementation priorities:**
- **Proposal Creation**: Community can propose upgrades
- **Voting Period**: 48-hour voting on upgrade proposals
- **Timelock Delay**: 24-hour delay before upgrade execution
- **Emergency Pause**: Immediate pause for critical vulnerabilities
- **Multi-sig Override**: Multi-sig can fast-track critical fixes

**Governance workflow:**
1. Proposal → 2. Community Vote → 3. Timelock → 4. Execution

### **Phase 2: Frontend Integration (Weeks 3-4)**

**Updated component architecture with proxy awareness:**
- ProxyGameManager.svelte - Manages proxy game instances
- UpgradeNotification.svelte - Notifies users of upgrades
- GameVersionChecker.svelte - Ensures frontend matches contract version
- ProxyGameRoom.svelte - Game interface with proxy state
- FactoryConnector.svelte - Connects to factory for new games
- GovernancePanel.svelte - Voting interface for upgrades

**State management with proxy patterns:**
- ProxyAwareState.ts - Handles proxy upgrades gracefully
- VersionCompatibility.ts - Manages version compatibility
- UpgradeWatcher.ts - Monitors for contract upgrades

### **Phase 3: Upgrade UX (Weeks 5-6)**

**Upgrade user experience:**
- **Seamless Upgrades**: Games continue without interruption
- **Version Notifications**: Users informed of new features
- **Backward Compatibility**: Old games still work during transition
- **Upgrade Benefits**: Clear communication of upgrade benefits
- **Rollback Support**: Ability to rollback problematic upgrades

### **Phase 4: Advanced Proxy Features (Weeks 7-8)**

**Advanced proxy functionality:**
- Multi-implementation support (A/B testing)
- Gradual rollout mechanisms
- Feature flag integration
- Emergency circuit breakers
- Cross-chain proxy synchronization

---

## 🛡️ **Security & Governance**

### **Upgrade Security Model**

**Multi-layered security for upgrades:**

**1. Role-based access control**
- UPGRADER_ROLE and EMERGENCY_ROLE definitions
- Granular permissions for different operations

**2. Timelock delays**
- UPGRADE_DELAY: 24 hours for standard upgrades
- EMERGENCY_DELAY: 1 hour for critical fixes

**3. Multi-signature requirements**
- REQUIRED_SIGNATURES: 3 of 5 signers
- Distributed control across trusted parties

**4. Community governance**
- VOTING_PERIOD: 48 hours for proposals
- EXECUTION_DELAY: 24 hours post-approval

**5. Emergency controls**
- Pause mechanisms for critical vulnerabilities
- Fast-track procedures for security fixes

### **Upgrade Governance Workflow**

**Governance process for upgrades:**
1. **Proposal Creation** (Any community member)
2. **Technical Review** (Core team + community)
3. **Voting Period** (48 hours, token-weighted)
4. **Timelock Period** (24 hours for implementation)
5. **Execution** (Automatic if passed)
6. **Monitoring** (24-hour monitoring period)
7. **Rollback Option** (If issues detected)

### **Emergency Response System**

**Emergency pause and upgrade system:**
- Immediate pause for critical vulnerabilities
- Fast-track critical security fixes with reduced timelock
- Emergency justification requirements
- Comprehensive event logging

---

## 💎 **Economic Design**

### **Proxy Gas Economics**

**Gas optimization through proxy patterns:**
- **Game Deployment**: ~50k gas (vs 2M+ for full contract)
- **Upgrade Propagation**: Single transaction upgrades all instances
- **Storage Efficiency**: Shared implementation reduces chain bloat
- **Batch Operations**: Factory enables batch game creation

**Cost comparison:**
- Traditional: 2M gas × 1000 games = 2B gas
- Beacon Proxy: 2M gas + (50k × 1000 games) = 52M gas (~96% savings)

### **Upgrade Incentive Alignment**

**Incentive structure for upgrades:**
- **Developer Fees**: 0.1% of game fees fund development
- **Governance Rewards**: Voters earn tokens for participation
- **Security Bounties**: Rewards for finding upgrade issues
- **Early Adopter Benefits**: Bonus rewards for using new features

### **Game Economics**

- **Entry Fees**: 0.001 - 0.01 ETH (Base/OP mainnet)
- **Winner Takes**: 90% of pot (10% to protocol)
- **Tournament**: Multi-tiered with increasing rewards
- **Spectator Betting**: Side bets on game outcomes

### **Token Integration**

**Future: Custom game token**
- stakeTournament: Stake tokens for tournament entry
- claimRewards: Claim game winnings and rewards
- voteGovernance: Participate in upgrade governance

---

## 📱 **MiniApp Integration Strategy**

### **MiniApp Architecture**

**Farcaster.json manifest configuration:**
- Account association with signed ownership proof
- Frame configuration with app metadata
- Required chains (Base) and capabilities
- Webhook endpoints for server integration

### **Environment Detection & Bootstrap**

**Detect if running as MiniApp vs standalone web:**
- Use Farcaster SDK to detect environment
- Different setup paths for MiniApp vs web
- Unified user experience across platforms

### **MiniApp State Management**

**Interface for MiniApp-specific state:**
- gameId, playerId, currentView
- gameState and pendingAction tracking
- Environment detection and provider access

### **MiniApp-Specific Features**

**Social integration within Farcaster:**
- Compose cast with game results
- Quick authentication without external wallet
- Native wallet integration via Farcaster
- Profile viewing and social features
- MiniApp collection integration

### **Progressive Web App Enhancement**

**Environment-specific UX:**
- Native Farcaster integration for MiniApp
- Standard web3 wallet connection for standalone
- Automatic vs manual onboarding flows

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
