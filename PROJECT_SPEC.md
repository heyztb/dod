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

```solidity
// Beacon Proxy Architecture for Scalable Upgrades
FarkleBeacon.sol         // Central beacon for game logic upgrades
FarkleGameBeacon.sol     // Beacon specifically for game instances
FarkleRoomsBeacon.sol    // Beacon for room management
FarkleTournamentsBeacon.sol  // Beacon for tournament logic

// Proxy Factory Pattern
FarkleProxyFactory.sol   // Deploys new game instances via BeaconProxy
FarkleRoomsFactory.sol   // Deploys room instances
FarkleTournamentFactory.sol // Deploys tournament brackets

// Core Implementation Contracts
FarkleGameImpl.sol       // Game logic implementation
FarkleRandomnessImpl.sol // VRF-based dice rolling implementation  
FarkleRoomsImpl.sol      // Room management implementation
FarkleTournamentsImpl.sol // Tournament bracket implementation
FarkleRewardsImpl.sol    // Prize pool and payout implementation

// Governance & Security
FarkleGovernor.sol       // Timelock governance for upgrades
FarkleTimelock.sol       // Timelock controller for upgrade delays
FarkleUpgradeAuthority.sol // Role-based upgrade permissions
```

### **Beacon Proxy Benefits for Gaming**

```typescript
// Why Beacon Proxy is Perfect for Farkle:
interface ProxyBenefits {
  gasEfficiency: "Deploy games for ~50k gas vs 2M+ for full contracts";
  coordinated_upgrades: "Upgrade all active games simultaneously";
  feature_rollouts: "Deploy new features to all instances at once";
  bug_fixes: "Critical fixes propagate to all games immediately";
  economic_updates: "Adjust scoring/rewards across all games";
  scalability: "Deploy 1000s of game instances cheaply";
}
```

### **Smart Contract Architecture**

```solidity
// Updated contract architecture with proxy patterns:

// 🏭 FACTORY CONTRACTS (Deploy New Instances)
FarkleGameFactory.sol     // Creates new game instances via BeaconProxy
FarkleRoomsFactory.sol    // Creates room instances for different game modes
FarkleTournamentFactory.sol // Creates tournament brackets

// 🎯 IMPLEMENTATION CONTRACTS (Upgradeable Logic)
FarkleGameImpl.sol        // Core game logic and state management
FarkleRandomnessImpl.sol  // Chainlink VRF integration
FarkleRoomsImpl.sol       // Room management and matchmaking
FarkleTournamentsImpl.sol // Tournament brackets and progression
FarkleRewardsImpl.sol     // Prize distribution and fee management
FarkleGovernanceImpl.sol  // Voting and upgrade proposals

// 🔮 BEACON CONTRACTS (Upgrade Coordination)
FarkleGameBeacon.sol      // Points to current FarkleGameImpl
FarkleRoomsBeacon.sol     // Points to current FarkleRoomsImpl
FarkleTournamentsBeacon.sol // Points to current FarkleTournamentsImpl
FarkleRewardsBeacon.sol   // Points to current FarkleRewardsImpl

// 🛡️ GOVERNANCE & SECURITY
FarkleTimelock.sol        // 48-hour delay on upgrades
FarkleMultiSig.sol        // Multi-signature upgrade authority
FarkleEmergencyPause.sol  // Circuit breaker for critical issues
```

### **Proxy Deployment Strategy**

```solidity
// Example: Creating a new game instance
contract FarkleGameFactory is AccessControl {
    UpgradeableBeacon public gameBeacon;
    
    event GameCreated(address indexed gameProxy, uint256 indexed gameId, address[] players);
    
    function createGame(
        address[] calldata players,
        uint256 entryFee,
        GameMode mode
    ) external returns (address gameProxy) {
        // Deploy new BeaconProxy pointing to current implementation
        gameProxy = address(new BeaconProxy(
            address(gameBeacon),
            abi.encodeWithSelector(
                FarkleGameImpl.initialize.selector,
                players,
                entryFee,
                mode,
                msg.sender
            )
        ));
        
        emit GameCreated(gameProxy, gameId, players);
        return gameProxy;
    }
    
    // Upgrade all game instances simultaneously
    function upgradeAllGames(address newImplementation) external onlyRole(UPGRADER_ROLE) {
        gameBeacon.upgradeTo(newImplementation);
    }
}
```

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
└─────────────────────────────────────────────────────────────────┘
```

### **Implementation Contract Design**

```solidity
// Base implementation contract with proper initialization
abstract contract FarkleBaseImpl is Initializable, UUPSUpgradeable, PausableUpgradeable {
    // State variables
    mapping(bytes32 => uint256) internal _gameStates;
    mapping(address => bool) internal _authorizedCallers;
    
    // Version tracking
    string public constant VERSION = "1.0.0";
    uint256 public lastUpgradeBlock;
    
    // Initialization instead of constructor
    function __FarkleBase_init(address owner) internal onlyInitializing {
        __Pausable_init();
        __UUPSUpgradeable_init();
        _transferOwnership(owner);
        lastUpgradeBlock = block.number;
    }
    
    // Upgrade authorization
    function _authorizeUpgrade(address newImplementation) 
        internal override onlyOwner whenNotPaused {}
    
    // Emergency pause functionality
    function emergencyPause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // Version compatibility check
    modifier onlyCompatibleVersion() {
        require(
            keccak256(abi.encodePacked(VERSION)) == getExpectedVersion(),
            "Version mismatch"
        );
        _;
    }
    
    function getExpectedVersion() internal pure virtual returns (bytes32);
}

// Specific game implementation
contract FarkleGameImpl is FarkleBaseImpl {
    using SafeERC20 for IERC20;
    
    // Game state
    struct GameState {
        address[2] players;
        uint256[2] scores;
        uint8 currentPlayer;
        uint256 entryFee;
        GameStatus status;
        uint256 randomSeed;
        TurnState currentTurn;
    }
    
    // Events
    event GameInitialized(address indexed gameProxy, address[] players);
    event DiceRolled(address indexed gameProxy, uint8[] dice);
    event TurnCompleted(address indexed gameProxy, address player, uint256 score);
    event GameEnded(address indexed gameProxy, address winner, uint256 prize);
    
    // Initialize game instance
    function initialize(
        address[] calldata players,
        uint256 entryFee,
        GameMode mode,
        address creator
    ) external initializer {
        require(players.length == 2, "Invalid player count");
        
        __FarkleBase_init(creator);
        
        // Initialize game state
        GameState storage game = _games[address(this)];
        game.players = [players[0], players[1]];
        game.entryFee = entryFee;
        game.status = GameStatus.WaitingForPlayers;
        
        emit GameInitialized(address(this), players);
    }
    
    // Core game functions
    function rollDice(uint8 numDice) external whenNotPaused nonReentrant {
        GameState storage game = _games[address(this)];
        require(game.players[game.currentPlayer] == msg.sender, "Not your turn");
        require(game.status == GameStatus.Active, "Game not active");
        
        // Request randomness from VRF
        _requestRandomness(numDice);
    }
    
    function selectDice(bool[] calldata selection) external whenNotPaused {
        GameState storage game = _games[address(this)];
        require(game.players[game.currentPlayer] == msg.sender, "Not your turn");
        
        // Validate selection and calculate score
        (uint256 score, bool hasScoringDice) = _calculateScore(
            game.currentTurn.dice, 
            selection
        );
        require(hasScoringDice, "No scoring dice selected");
        
        // Update turn state
        game.currentTurn.selectedDice = selection;
        game.currentTurn.turnScore += score;
        
        emit DiceSelected(address(this), selection, score);
    }
    
    function bankTurn() external whenNotPaused {
        GameState storage game = _games[address(this)];
        require(game.players[game.currentPlayer] == msg.sender, "Not your turn");
        require(game.currentTurn.turnScore > 0, "No score to bank");
        
        // Bank the turn score
        game.scores[game.currentPlayer] += game.currentTurn.turnScore;
        
        // Check for win condition
        if (game.scores[game.currentPlayer] >= WINNING_SCORE) {
            _endGame(game.currentPlayer);
        } else {
            _nextTurn();
        }
        
        emit TurnCompleted(address(this), msg.sender, game.currentTurn.turnScore);
    }
    
    // Internal functions
    function _endGame(uint8 winner) internal {
        GameState storage game = _games[address(this)];
        game.status = GameStatus.Finished;
        
        // Transfer prize to winner
        uint256 prize = game.entryFee * 2 * 90 / 100; // 90% to winner
        uint256 fee = game.entryFee * 2 * 10 / 100;   // 10% protocol fee
        
        payable(game.players[winner]).transfer(prize);
        
        emit GameEnded(address(this), game.players[winner], prize);
    }
    
    // Version compatibility
    function getExpectedVersion() internal pure override returns (bytes32) {
        return keccak256(abi.encodePacked("1.0.0"));
    }
}
```

### **Factory Implementation Guide**

```solidity
// Comprehensive factory for game deployment
contract FarkleGameFactory is AccessControl, ReentrancyGuard {
    using Address for address;
    
    // Roles
    bytes32 public constant GAME_CREATOR_ROLE = keccak256("GAME_CREATOR_ROLE");
    bytes32 public constant BEACON_MANAGER_ROLE = keccak256("BEACON_MANAGER_ROLE");
    
    // State
    UpgradeableBeacon public immutable gameBeacon;
    mapping(address => bool) public isGameProxy;
    address[] public allGames;
    
    // Events
    event GameCreated(
        address indexed gameProxy, 
        uint256 indexed gameId, 
        address[] players,
        uint256 entryFee
    );
    event BeaconUpgraded(address indexed newImplementation);
    
    constructor(address gameImplementation) {
        gameBeacon = new UpgradeableBeacon(gameImplementation);
        gameBeacon.transferOwnership(msg.sender);
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GAME_CREATOR_ROLE, msg.sender);
        _grantRole(BEACON_MANAGER_ROLE, msg.sender);
    }
    
    // Create new game instance
    function createGame(
        address[] calldata players,
        uint256 entryFee,
        GameMode mode
    ) external payable nonReentrant returns (address gameProxy) {
        require(players.length == 2, "Invalid player count");
        require(msg.value >= entryFee * players.length, "Insufficient payment");
        
        // Deploy new BeaconProxy
        bytes memory initData = abi.encodeWithSelector(
            FarkleGameImpl.initialize.selector,
            players,
            entryFee,
            mode,
            msg.sender
        );
        
        gameProxy = address(new BeaconProxy(address(gameBeacon), initData));
        
        // Track the game
        isGameProxy[gameProxy] = true;
        allGames.push(gameProxy);
        
        // Transfer entry fees to game contract
        payable(gameProxy).transfer(msg.value);
        
        emit GameCreated(gameProxy, allGames.length - 1, players, entryFee);
        return gameProxy;
    }
    
    // Batch create games (gas optimization)
    function createGames(
        address[][] calldata playerSets,
        uint256[] calldata entryFees,
        GameMode[] calldata modes
    ) external payable nonReentrant returns (address[] memory gameProxies) {
        require(playerSets.length == entryFees.length, "Length mismatch");
        require(playerSets.length == modes.length, "Length mismatch");
        
        gameProxies = new address[](playerSets.length);
        
        for (uint256 i = 0; i < playerSets.length; i++) {
            gameProxies[i] = createGame(playerSets[i], entryFees[i], modes[i]);
        }
        
        return gameProxies;
    }
    
    // Upgrade all games
    function upgradeAllGames(address newImplementation) 
        external 
        onlyRole(BEACON_MANAGER_ROLE) 
    {
        require(newImplementation.isContract(), "Not a contract");
        gameBeacon.upgradeTo(newImplementation);
        emit BeaconUpgraded(newImplementation);
    }
    
    // View functions
    function getGameCount() external view returns (uint256) {
        return allGames.length;
    }
    
    function getGames(uint256 offset, uint256 limit) 
        external 
        view 
        returns (address[] memory) 
    {
        require(offset < allGames.length, "Offset out of bounds");
        
        uint256 end = offset + limit;
        if (end > allGames.length) {
            end = allGames.length;
        }
        
        address[] memory games = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            games[i - offset] = allGames[i];
        }
        
        return games;
    }
}
```

### **Onchain Game State**

```typescript
// Updated interface with proxy-aware architecture
interface ProxyGameState {
  gameId: bigint;
  proxyAddress: string;        // Address of this game's proxy
  implementationVersion: string; // Track which impl version
  players: [Player, Player];
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
  randomSeed: bigint;
  
  // Proxy-specific fields
  upgradeable: boolean;        // Can this game be upgraded?
  pausable: boolean;          // Can this game be paused?
  lastUpgrade: bigint;        // Block number of last upgrade
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

### **Phase 1: Proxy Infrastructure (Weeks 1-2)**

```solidity
// Updated development priorities:
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
```

### **Phase 1.5: Upgrade Governance (Week 2.5)**

```typescript
// Governance implementation priorities:
interface UpgradeGovernance {
  proposal_creation: "Community can propose upgrades";
  voting_period: "48-hour voting on upgrade proposals";
  timelock_delay: "24-hour delay before upgrade execution";
  emergency_pause: "Immediate pause for critical vulnerabilities";
  multi_sig_override: "Multi-sig can fast-track critical fixes";
}

// Governance workflow:
1. Proposal → 2. Community Vote → 3. Timelock → 4. Execution
```

### **Phase 2: Frontend Integration (Weeks 3-4)**

```typescript
// Updated component architecture with proxy awareness:
-ProxyGameManager.svelte    // Manages proxy game instances
-UpgradeNotification.svelte // Notifies users of upgrades
-GameVersionChecker.svelte  // Ensures frontend matches contract version
-ProxyGameRoom.svelte      // Game interface with proxy state
-FactoryConnector.svelte   // Connects to factory for new games
-GovernancePanel.svelte    // Voting interface for upgrades

// State management with proxy patterns:
-ProxyAwareState.ts        // Handles proxy upgrades gracefully
-VersionCompatibility.ts   // Manages version compatibility
-UpgradeWatcher.ts         // Monitors for contract upgrades
```

### **Phase 3: Upgrade UX (Weeks 5-6)**

```typescript
// Upgrade user experience:
interface UpgradeUX {
  seamless_upgrades: "Games continue without interruption";
  version_notifications: "Users informed of new features";
  backward_compatibility: "Old games still work during transition";
  upgrade_benefits: "Clear communication of upgrade benefits";
  rollback_support: "Ability to rollback problematic upgrades";
}
```

### **Phase 4: Advanced Proxy Features (Weeks 7-8)**

```typescript
// Advanced proxy functionality:
- Multi-implementation support (A/B testing)
- Gradual rollout mechanisms
- Feature flag integration
- Emergency circuit breakers
- Cross-chain proxy synchronization
```

---

## 🛡️ **Security & Governance**

### **Upgrade Security Model**

```solidity
// Multi-layered security for upgrades:
contract FarkleUpgradeSecurity {
    // 1. Role-based access control
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    // 2. Timelock delays
    uint256 public constant UPGRADE_DELAY = 24 hours;
    uint256 public constant EMERGENCY_DELAY = 1 hours;
    
    // 3. Multi-signature requirements
    uint256 public constant REQUIRED_SIGNATURES = 3;
    uint256 public constant TOTAL_SIGNERS = 5;
    
    // 4. Community governance
    uint256 public constant VOTING_PERIOD = 48 hours;
    uint256 public constant EXECUTION_DELAY = 24 hours;
    
    // 5. Emergency controls
    mapping(address => bool) public emergencyPaused;
    
    modifier onlyAfterDelay(uint256 proposalTime) {
        require(block.timestamp >= proposalTime + UPGRADE_DELAY, "Timelock not expired");
        _;
    }
}
```

### **Upgrade Governance Workflow**

```typescript
// Governance process for upgrades:
interface GovernanceWorkflow {
  step1: "Proposal Creation (Any community member)";
  step2: "Technical Review (Core team + community)";
  step3: "Voting Period (48 hours, token-weighted)";
  step4: "Timelock Period (24 hours for implementation)";
  step5: "Execution (Automatic if passed)";
  step6: "Monitoring (24-hour monitoring period)";
  step7: "Rollback Option (If issues detected)";
}
```

### **Emergency Response System**

```solidity
// Emergency pause and upgrade system:
contract FarkleEmergencySystem {
    event EmergencyPause(address indexed contract, string reason);
    event EmergencyUpgrade(address indexed beacon, address newImpl, string reason);
    
    // Immediate pause for critical vulnerabilities
    function emergencyPause(address target, string calldata reason) 
        external onlyRole(EMERGENCY_ROLE) {
        IPausable(target).pause();
        emit EmergencyPause(target, reason);
    }
    
    // Fast-track critical security fixes
    function emergencyUpgrade(
        address beacon, 
        address newImpl, 
        string calldata reason
    ) external onlyRole(EMERGENCY_ROLE) {
        // Reduced timelock for critical fixes
        require(isEmergencyJustified(reason), "Not emergency");
        UpgradeableBeacon(beacon).upgradeTo(newImpl);
        emit EmergencyUpgrade(beacon, newImpl, reason);
    }
}
```

---

## 💎 **Economic Design**

### **Proxy Gas Economics**

```solidity
// Gas optimization through proxy patterns:
interface ProxyGasEconomics {
  game_deployment: "~50k gas (vs 2M+ for full contract)";
  upgrade_propagation: "Single transaction upgrades all instances";
  storage_efficiency: "Shared implementation reduces chain bloat";
  batch_operations: "Factory enables batch game creation";
}

// Cost comparison:
// Traditional: 2M gas × 1000 games = 2B gas
// Beacon Proxy: 2M gas + (50k × 1000 games) = 52M gas (~96% savings)
```

### **Upgrade Incentive Alignment**

```typescript
// Incentive structure for upgrades:
interface UpgradeIncentives {
  developer_fees: "0.1% of game fees fund development";
  governance_rewards: "Voters earn tokens for participation";
  security_bounties: "Rewards for finding upgrade issues";
  early_adopter_benefits: "Bonus rewards for using new features";
}
```

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
