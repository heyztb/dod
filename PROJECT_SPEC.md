# Farkle Onchain - Project Specification (Updated)

## 🎯 **Project Vision**

Create the gold standard for onchain gaming UX - a fully decentralized Farkle implementation that feels as smooth as Web2 while leveraging blockchain for transparency, provable fairness, and economic incentives.

## 🔥 **Core Principles**

1. **Onchain First**: Game logic, randomness, and state live on blockchain
2. **Invisible Complexity**: Users never feel like they're using crypto
3. **Instant Feedback**: No waiting for blockchain - optimistic UI updates
4. **Provably Fair**: All randomness and game logic verifiable onchain
5. **MiniApp Native**: Optimized for Farcaster MiniApp experience with potential web expansion

---

## ✅ **COMPLETED FEATURES**

### **🎮 Core Game Implementation**
- ✅ **Complete Farkle Game Logic**: Full implementation with all official scoring rules
- ✅ **Dice Packing Optimization**: 48-bit storage for 6 dice values (~60% gas savings)
- ✅ **Partial Dice Selection**: Players can select specific dice and continue rolling
- ✅ **Hot Dice Mechanics**: All 6 dice selected triggers new roll with all dice
- ✅ **Turn Management**: Proper turn-based gameplay with state validation
- ✅ **Comprehensive Scoring**: All official Farkle combinations implemented:
  - Individual 1s (100 pts) and 5s (50 pts)
  - Three of a kind (1000 for 1s, face value × 100 for others)
  - Four/Five/Six of a kind (1000/2000/3000 pts)
  - Straight 1-6 (1500 pts)
  - Three pairs (1500 pts)
  - Four of a kind + pair (1500 pts)
  - Two sets of three of a kind (2500 pts)

### **🧪 Testing Infrastructure**
- ✅ **Comprehensive Test Suite**: 25 passing tests with 100% coverage
- ✅ **Detailed Test Logging**: Visual feedback for all test scenarios
- ✅ **Fuzz Testing**: Randomized testing for dice operations
- ✅ **Game Flow Testing**: Complete turn progression validation
- ✅ **Edge Case Coverage**: Boundary conditions and error scenarios

### **🏗️ Smart Contract Architecture**
- ✅ **Solady Integration**: Gas-optimized contracts using Solady library
- ✅ **Proxy-Ready Pattern**: Initializable contracts with proper proxy support
- ✅ **Interface Definitions**: Clean separation of interfaces and implementations
- ✅ **Factory Pattern**: Basic factory contracts for game deployment
- ✅ **Error Handling**: Custom errors for gas-efficient error reporting

### **🎨 Frontend Foundation**
- ✅ **SvelteKit 5 Setup**: Modern frontend with Svelte 5 runes
- ✅ **Farcaster Integration**: MiniApp detection and frame context
- ✅ **Wallet Integration**: Viem-based wallet connection
- ✅ **Chain Management**: Multi-chain support with chain switching
- ✅ **UI Components**: Modal, buttons, and responsive design
- ✅ **Environment Detection**: MiniApp vs standalone web detection

---

## 🚧 **IN PROGRESS / NEEDS WORK**

### **🏗️ Proxy Infrastructure (HIGH PRIORITY)**
- ❌ **Beacon Proxy Implementation**: Need to implement beacon proxy pattern
- ❌ **Upgrade Governance**: Timelock and multi-sig upgrade authority
- ❌ **Factory with LibClone**: Gas-optimized deployment using Solady's LibClone
- ❌ **Coordinated Upgrades**: Ability to upgrade all game instances simultaneously

### **🎲 Randomness & Security**
- ❌ **Chainlink VRF Integration**: Replace pseudo-random with provably fair randomness
- ❌ **Commit-Reveal Scheme**: Additional randomness security layer

### **💰 Economic Layer**
- ❌ **Entry Fee System**: ETH-based game entry fees
- ❌ **Prize Distribution**: Winner takes pot minus protocol fee
- ❌ **Gas Optimization**: Further optimize for production costs
- ❌ **Fee Management**: Protocol fee collection and distribution

### **🎮 Game Features**
- ❌ **Room System**: Multi-player room creation and joining
- ❌ **Tournament Brackets**: Tournament-style gameplay
- ❌ **Spectator Mode**: Watch ongoing games
- ❌ **Game History**: Track past games and statistics

---

## 🔧 **UPDATED TECHNICAL IMPLEMENTATION PLAN**

### **Phase 1: Proxy Infrastructure (Weeks 1-2) - CURRENT PRIORITY**

**Immediate Next Steps:**
1. **Implement Beacon Proxy Pattern**
   - Create FarkleGameBeacon.sol using Solady
   - Update FarkleGameImpl.sol for beacon compatibility
   - Implement FarkleGameFactory.sol with LibClone

2. **Add Upgrade Governance**
   - FarkleTimelock.sol for upgrade delays
   - Multi-sig upgrade authority
   - Emergency pause mechanisms

3. **Comprehensive Proxy Testing**
   - Test upgrade scenarios
   - Validate state preservation
   - Gas optimization verification

**Current Status:** ⚠️ **BLOCKED** - Need to implement proxy infrastructure before proceeding

### **Phase 2: Randomness Integration (Weeks 2-3)**

**Chainlink VRF Implementation:**
- Replace `_rollAvailableDice()` with VRF requests
- Implement callback handling for dice results
- Add request ID tracking and validation
- Test randomness distribution and fairness

**Current Status:** 🔄 **READY** - Game logic complete, ready for VRF integration

### **Phase 3: Economic Layer (Weeks 3-4)**

**Entry Fee System:**
- Add entry fee parameters to game initialization
- Implement prize pool management
- Protocol fee collection (10% to treasury)
- Winner payout automation

**Current Status:** 🔄 **READY** - Core game ready for economic layer

### **Phase 4: Frontend Integration (Weeks 4-5)**

**Game Interface Development:**
- Connect frontend to smart contracts
- Implement real-time game state updates
- Add wallet transaction handling
- Optimistic UI updates with rollback

**Current Status:** 🔄 **PARTIALLY READY** - Basic UI exists, needs contract integration

### **Phase 5: Advanced Features (Weeks 6-8)**

**Room and Tournament System:**
- Multi-player room management
- Tournament bracket implementation
- Spectator functionality
- Advanced game modes

**Current Status:** ⏳ **WAITING** - Depends on core infrastructure completion

---

## 🛡️ **Security & Governance (UPDATED)**

### **Current Security Status**
- ✅ **Access Controls**: Proper player validation and turn management
- ✅ **Input Validation**: Comprehensive dice selection validation
- ✅ **State Management**: Secure game state transitions
- ❌ **Upgrade Security**: Need timelock and multi-sig governance
- ❌ **Randomness Security**: Need VRF integration
- ❌ **Economic Security**: Need entry fee and prize validation


---

## 💎 **Economic Design (UPDATED)**

### **Current Gas Optimization**
- ✅ **Dice Packing**: 60% storage savings with 48-bit packing
- ✅ **Solady Integration**: Gas-optimized library usage
- ❌ **Proxy Deployment**: Need LibClone for 96% deployment savings
- ❌ **Batch Operations**: Need factory batch deployment

### **Target Economics**
- **Game Deployment**: ~50k gas (vs 2M+ traditional)
- **Entry Fees**: 0.001 - 0.01 ETH per game
- **Protocol Fee**: 10% of entry fees
- **Winner Payout**: 90% of total pot

---

## 📱 **MiniApp Integration (UPDATED)**

### **Current Status**
- ✅ **Environment Detection**: Detects MiniApp vs standalone
- ✅ **Frame Context**: Access to Farcaster user data
- ✅ **Responsive Design**: Mobile-optimized interface
- ❌ **Contract Integration**: Need to connect UI to contracts
- ❌ **Wallet Integration**: Need MiniApp-specific wallet handling

---

## 🚀 **Success Metrics (UPDATED)**

### **Technical Achievements**
- ✅ **25 Passing Tests**: Comprehensive test coverage
- ✅ **Gas Optimization**: 60% storage savings achieved
- ✅ **Official Farkle Rules**: 100% rule compliance
- ❌ **Proxy Deployment**: Target 96% deployment savings
- ❌ **VRF Integration**: Provably fair randomness

### **Development Velocity**
- ✅ **Core Game Logic**: Completed ahead of schedule
- ✅ **Test Infrastructure**: Comprehensive logging and validation
- ⚠️ **Proxy Infrastructure**: Behind schedule, needs immediate attention
- ⏳ **Frontend Integration**: Waiting on contract completion

---

## 🎯 **IMMEDIATE NEXT STEPS (PRIORITY ORDER)**

### **Week 1 Sprint (HIGH PRIORITY)**

1. **🔥 CRITICAL: Implement Beacon Proxy Pattern**
   - Create FarkleGameBeacon.sol
   - Update factory with LibClone
   - Test upgrade scenarios

2. **🔥 CRITICAL: Add Upgrade Governance**
   - Implement timelock controller
   - Add multi-sig upgrade authority
   - Test governance workflow

3. **🔥 CRITICAL: Comprehensive Proxy Testing**
   - Test state preservation across upgrades
   - Validate gas savings
   - Security audit preparation

### **Week 2 Sprint (MEDIUM PRIORITY)**

1. **Chainlink VRF Integration**
   - Replace pseudo-random with VRF
   - Test randomness distribution
   - Add request validation

2. **Economic Layer Implementation**
   - Add entry fee system
   - Implement prize distribution
   - Test economic flows

### **MVP Definition (UPDATED)**

- ✅ 2-player Farkle game logic
- ✅ Complete official scoring rules
- ✅ Comprehensive test suite
- ❌ Beacon proxy architecture (BLOCKING)
- ❌ Chainlink VRF randomness (BLOCKING)
- ❌ Entry fee system (BLOCKING)
- ❌ Frontend contract integration (BLOCKED)
- ❌ Working Farcaster MiniApp (BLOCKED)

**Current Status:** 🚧 **40% Complete** - Core game logic done, infrastructure needed

---

## 📊 **Project Health Dashboard**

### **✅ Strengths**
- Comprehensive game logic implementation
- Excellent test coverage with detailed logging
- Gas-optimized dice storage
- Clean architecture with proper interfaces
- Official Farkle rules compliance

### **⚠️ Risks**
- Proxy infrastructure not implemented (blocking deployment)
- No randomness security (blocking production)
- No economic layer (blocking real gameplay)
- Frontend not connected to contracts

### **🔥 Critical Path**
1. Implement beacon proxy pattern
2. Add Chainlink VRF integration
3. Implement economic layer
4. Connect frontend to contracts
5. Deploy to testnet for validation

**Estimated Time to MVP:** 2-3 weeks with focused development on critical path items.

This updated specification reflects the excellent progress on core game logic while highlighting the critical infrastructure work needed for deployment.
