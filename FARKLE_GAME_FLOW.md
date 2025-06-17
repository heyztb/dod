# Farkle Game Flow Documentation

## Overview
This document outlines the complete game flow for the Farkle game implementation, from room creation through game completion. It includes current implementation status, missing features, and future enhancements.

## Game Architecture

### Smart Contracts
- **FarkleRoomFactory**: Creates and manages game rooms (lobbies)
- **FarkleGameFactory**: Creates game instances from rooms
- **FarkleRoomImpl**: Pre-game lobby implementation
- **FarkleGameImpl**: Core game logic implementation
- **UpgradeableBeacon**: Proxy pattern for contract upgrades

### Frontend Components
- **Lobby Page**: Main entry point with Host/Join game buttons
- **Game Page**: Active game interface (currently empty)
- **Room Management**: Player joining/leaving functionality
- **Wallet Integration**: Via Viem and Frame integration

## Complete Game Flow

### Phase 1: Pre-Game (Room/Lobby)

#### 1.1 Room Creation
**Current Status**: ✅ Implemented
- Player clicks "Host Game" in lobby
- FarkleRoomFactory creates new FarkleRoomImpl instance
- Room configured with max players (default: configurable)
- Room creator becomes owner
- Room gets unique ID for sharing

#### 1.2 Room Joining
**Current Status**: ✅ Partially Implemented
- Players can join via room ID or invitation
- FarkleRoomImpl validates:
  - Room not full (maxPlayers limit)
  - Player not already in room
- Emits `PlayerJoined` event
- Updates room player list

#### 1.3 Room Management
**Current Status**: ✅ Basic Implementation
- Players can leave room before game starts
- Room owner can kick players (TODO: add this functionality)
- Room automatically starts when minimum players joined (TODO: implement)
- Room deletion when empty (TODO: implement cleanup)

#### 1.4 Chat Integration (Future Feature)
**Current Status**: ❌ Not Implemented
- **TODO**: Investigate XMTP for chat functionality
- Enable text chat in pre-game lobby
- Continue chat during active game
- Persistent chat history
- Consider moderation features

### Phase 2: Game Initialization

#### 2.1 Game Start Trigger
**Current Status**: ❌ Not Implemented
- Triggered when:
  - Room owner starts game manually, OR
  - Room reaches max capacity (auto-start), OR
  - Timer expires with minimum players
- Validates minimum 2 players present

#### 2.2 Game Instance Creation
**Current Status**: ✅ Implemented
- FarkleGameFactory creates FarkleGameImpl instance
- Players array transferred from room to game
- Initial game state set:
  - Current player = 0 (first player)
  - All player scores = 0
  - Dice state reset
- Room marked as "game in progress"

### Phase 3: Active Game Loop

#### 3.1 Turn Structure
**Current Status**: ✅ Implemented
Each player turn consists of:
1. **Roll Phase**: Player rolls available dice
2. **Selection Phase**: Player selects scoring dice
3. **Decision Phase**: Player chooses to continue rolling or bank points
4. **End Turn**: Turn passes to next player

#### 3.2 Roll Phase
**Current Status**: ✅ Implemented
- Player calls `roll()` function
- Only unselected dice are rolled (selected dice preserved)
- Pseudo-random generation using block data
- Emits `DiceThrown` event with new values
- Automatic Farkle check on new dice

#### 3.3 Dice Selection Phase
**Current Status**: ✅ Implemented
- Player calls `selectDice(uint8[] indices)`
- Validation checks:
  - Must have rolled first
  - Indices must be valid (0-5)
  - Dice not already selected
  - Selection must score points
- Score calculation for selected dice only
- Updates turn score and selected mask
- Emits `DiceSelected` event

#### 3.4 Scoring System
**Current Status**: ✅ Fully Implemented
All official Farkle scoring rules implemented:

**Individual Dice**:
- Single 1 = 100 points
- Single 5 = 50 points

**Three of a Kind**:
- Three 1s = 1,000 points
- Three 2s = 200 points
- Three 3s = 300 points
- Three 4s = 400 points
- Three 5s = 500 points
- Three 6s = 600 points

**Multiple of a Kind**:
- Four of a kind = 1,000 points
- Five of a kind = 2,000 points
- Six of a kind = 3,000 points

**Special Combinations**:
- Straight (1-6) = 1,500 points
- Three pairs = 1,500 points
- Four of a kind + pair = 1,500 points
- Two sets of three of a kind = 2,500 points

#### 3.5 Hot Dice Handling
**Current Status**: ✅ Implemented
- When all 6 dice are selected (scoring)
- Dice state resets: selectedMask = 0, availableCount = 6
- Player must roll again with all 6 dice
- Turn score accumulates across hot dice rounds

#### 3.6 Banking Points
**Current Status**: ✅ Implemented
- Player calls `bank()` function
- Validates player has rolled at least once
- Adds turn score to player's total score
- Emits `Banked` event
- Advances to next player
- Resets dice state for next turn

#### 3.7 Farkle Handling
**Current Status**: ✅ Implemented
- Triggered when no scoring dice in a roll
- Player loses entire turn score
- Emits `Farkled` event
- Turn immediately passes to next player
- Dice state reset

### Phase 4: Game Completion

#### 4.1 Winning Condition Check
**Current Status**: ❌ Not Implemented
- **TODO**: Implement 10,000 point threshold detection
- **TODO**: Implement final round logic
- When player reaches/exceeds 10,000 points:
  - Mark game as "final round"
  - Allow each other player one final turn
  - Determine winner (highest score)

#### 4.2 Game End
**Current Status**: ❌ Not Implemented
- **TODO**: Implement game completion logic
- **TODO**: Emit game end events
- **TODO**: Update player statistics
- **TODO**: Clean up game state

## Implementation Status Summary

### ✅ Completed Features
- Core dice mechanics (rolling, packing/unpacking)
- Complete scoring system (all Farkle rules)
- Dice selection and validation
- Hot dice handling
- Farkle detection
- Turn management
- Basic room functionality
- Player joining/leaving rooms

### 🔄 Partial Implementation
- Room management (missing auto-start, cleanup)
- Game initialization (missing room-to-game transition)
- Frontend UI (lobby done, game UI empty)

### ❌ Missing Critical Features
- Game start trigger from rooms
- Win condition detection (10,000 points)
- Final round logic
- Game completion handling
- Player statistics tracking
- Game history/leaderboard

### 🔮 Future Enhancements
- **XMTP Chat Integration**:
  - Real-time chat in rooms and games
  - Player communication
  - Chat history persistence
  - Moderation tools
- **Advanced Room Features**:
  - Private rooms with passwords
  - Room settings (scoring variants, time limits)
  - Spectator mode
  - Rejoin functionality
- **Social Features**:
  - Player profiles
  - Friend systems
  - Tournament mode
  - Achievements/badges

## Technical Notes

### Gas Optimization
- Dice values packed into uint48 (8 bits per die)
- Bit masking for selected dice tracking
- Hybrid approach balancing gas costs with readability

### Security Considerations
- Pseudo-random number generation using block data
- Player turn validation
- Input validation on all functions
- Access control via modifiers

### Testing Coverage
- Comprehensive unit tests for scoring logic
- Dice packing/unpacking verification
- Edge case handling (farkles, hot dice)
- **TODO**: Integration tests for full game flow

## Next Development Priorities

1. **Complete Game Flow**: Implement win condition and game completion
2. **Frontend Game UI**: Build interactive dice selection interface
3. **Room-to-Game Transition**: Connect room system to game creation
4. **XMTP Investigation**: Research and prototype chat integration
5. **Player Statistics**: Track games, wins, high scores
6. **Mobile Optimization**: Ensure responsive design for mobile play

## XMTP Chat Integration Notes

**Investigation Tasks**:
- Research XMTP SDK integration with SvelteKit
- Evaluate message persistence options
- Design chat UI components for rooms and active games
- Consider moderation and spam prevention
- Assess gas costs for message broadcasting
- Plan fallback options if XMTP unavailable

**Potential Implementation**:
- Initialize XMTP client on wallet connection
- Create conversation groups per room/game
- Integrate chat UI into room and game layouts
- Store conversation references in room contracts
- Enable message reactions and game state updates 