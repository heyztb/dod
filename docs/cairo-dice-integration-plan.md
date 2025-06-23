# Cairo Dice Roller Integration Plan for Farkle Game

## Executive Summary

This document outlines the technical integration plan for incorporating the Cairo-based provably fair dice rolling system into the existing Farkle game application. The integration will replace the current pseudo-random dice generation with a commit-reveal scheme that ensures provable fairness while maintaining game performance and user experience.

## Current State Analysis

### Existing Farkle Game Architecture

The current Farkle game implementation (`FarkleGameImpl.sol`) uses:

- **Dice Representation**: Hybrid approach with `uint48` packed storage for 6 dice values
- **Random Generation**: `keccak256` hash of `block.timestamp`, `block.prevrandao`, `msg.sender`, and `dice.turnScore`
- **Dice State Management**: Efficient bit-packed storage with selection masks
- **Game Logic**: Complete Farkle rule implementation with proper scoring

**Current Limitations**:
- Pseudo-random generation is predictable and not provably fair
- Players cannot verify the fairness of dice rolls
- Susceptible to manipulation by miners or validators
- No auditability of randomness source

### Cairo Dice Roller Analysis

The Cairo application (`cairoroller/src/lib.cairo`) provides:

- **Hash Chain Generation**: Uses Pedersen hashing for deterministic randomness
- **Commit-Reveal Scheme**: Supports commitment publishing before rolling
- **Provable Fairness**: All rolls are verifiable using the revealed seed
- **Batch Rolling**: Efficient generation of multiple dice values
- **Distribution Analysis**: Python tooling for fairness verification

**Key Features**:
- Deterministic but unpredictable dice generation
- Cryptographically sound using Pedersen hashing
- Supports unlimited dice rolls per seed (with checkpoint upgrades planned)
- Built-in commitment scheme for transparency

## Integration Architecture

### 1. Hybrid Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Ethereum      │    │   Cairo Prover   │    │   Frontend      │
│   Farkle Game   │    │   Dice Roller    │    │   Application   │
│                 │    │                  │    │                 │
│ • Game Logic    │◄──►│ • Dice Rolling   │◄──►│ • Commitment UI │
│ • State Mgmt    │    │ • Proof Gen      │    │ • Verification  │
│ • Scoring       │    │ • Verification   │    │ • Game Display  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### 2. Component Integration Strategy

#### Phase 1: Off-Chain Proving with Artifact-Based Verification
- Cairo prover runs off-chain to generate dice rolls and proof artifacts
- Ethereum contract accepts dice values after commitment reveal
- Players can verify fairness using Cairo-generated artifacts and tooling

#### Phase 2: Hybrid Validation
- Combine Cairo proving with Ethereum's existing randomness
- Use Cairo for dice generation, Ethereum for game state management
- Maintain current game performance while adding provable fairness

## Technical Implementation Plan

### 1. Smart Contract Modifications

#### A. Enhanced Dice State Structure

```solidity
struct DiceState {
    uint48 values;              // Current dice values (existing)
    uint8 selectedMask;         // Selected dice mask (existing)
    uint8 availableCount;       // Available dice count (existing)
    uint32 turnScore;           // Turn score (existing)
    bool hasRolled;            // Roll status (existing)
    uint32 rollIndex;          // Current roll index in hash chain
}

// Game-level commitment (stored once per game)
struct GameCommitment {
    bytes32 commitment;         // Hash of master seed (set at room creation)
    bytes32 seed;              // Master seed (revealed when game ends)
    bool seedRevealed;         // Whether seed has been revealed
    uint256 commitmentTime;    // Timestamp of commitment
    string artifactURI;        // IPFS/storage URI for all game artifacts
}
```

#### B. Game-Level Commitment Functions

```solidity
// Add to contract state
GameCommitment public gameCommitment;

// Called during room/game initialization
function initializeWithCommitment(
    address _room, 
    address[] calldata _players,
    bytes32 _commitment
) external initializer {
    _initializeOwner(msg.sender);
    room = _room;
    players = _players;
    
    // Initialize player scores
    for (uint256 i = 0; i < _players.length; i++) {
        playerScores[_players[i]] = 0;
    }
    
    // Set up game commitment
    gameCommitment = GameCommitment({
        commitment: _commitment,
        seed: bytes32(0),
        seedRevealed: false,
        commitmentTime: block.timestamp,
        artifactURI: ""
    });
    
    // Initialize dice state
    dice = DiceState({
        values: 0,
        selectedMask: 0,
        availableCount: 6,
        turnScore: 0,
        hasRolled: false,
        rollIndex: 0
    });
    
    emit GameCommitted(_commitment);
}

// Modified roll function - no longer needs commitment
function roll() external override onlyCurrentPlayer {
    require(dice.availableCount > 0, "No dice available");
    require(!gameCommitment.seedRevealed, "Game ended, seed revealed");
    
    // Generate dice using current roll index
    uint8[6] memory newValues = _rollWithIndex(dice.rollIndex);
    dice.values = _packDiceValues(newValues);
    dice.hasRolled = true;
    dice.rollIndex++; // Increment for next roll
    
    emit DiceThrown(msg.sender, dice.values);
    
    // Check for farkle
    if (!_hasAnyScore(newValues)) {
        _farkle();
    }
}

// Called when game ends to reveal seed and artifacts
function revealGameSeed(
    bytes32 _seed,
    string calldata _artifactURI
) external onlyOwner {
    require(!gameCommitment.seedRevealed, "Seed already revealed");
    
    // Verify commitment matches seed
    require(keccak256(abi.encode(_seed)) == gameCommitment.commitment, "Invalid seed");
    
    gameCommitment.seed = _seed;
    gameCommitment.seedRevealed = true;
    gameCommitment.artifactURI = _artifactURI;
    
    emit GameSeedRevealed(_seed, _artifactURI);
}
```

#### C. Dice Generation with Hash Chain

```solidity
// Additional events for Cairo integration
event GameCommitted(bytes32 commitment);
event GameSeedRevealed(bytes32 seed, string artifactURI);

// Replace the existing _rollAvailableDice function
function _rollWithIndex(uint32 rollIndex) internal view returns (uint8[6] memory) {
    uint8[6] memory values = _unpackDiceValues(dice.values);
    
    // Use deterministic generation based on roll index
    // This will be verified against Cairo execution after game ends
    uint256 pseudoSeed = uint256(keccak256(
        abi.encodePacked(gameCommitment.commitment, rollIndex, block.timestamp)
    ));
    
    // Only roll unselected dice
    for (uint256 i = 0; i < 6; i++) {
        if ((dice.selectedMask & (1 << i)) == 0) {
            values[i] = uint8((pseudoSeed >> (i * 8)) % 6) + 1;
        }
    }
    
    return values;
}

// View functions for game verification
function getGameCommitment() external view returns (
    bytes32 commitment,
    bytes32 seed,
    bool seedRevealed,
    string memory artifactURI
) {
    return (
        gameCommitment.commitment,
        gameCommitment.seed,
        gameCommitment.seedRevealed,
        gameCommitment.artifactURI
    );
}

function getCurrentRollIndex() external view returns (uint32) {
    return dice.rollIndex;
}
```

### 2. Cairo Artifacts and Verification

The Cairo application generates several artifacts during execution that enable off-chain verification:

#### A. Generated Artifacts
```json
{
  "execution_trace": {
    "air_public_input.json": "Public inputs to the Cairo program",
    "air_private_input.json": "Private execution trace data", 
    "memory.bin": "Memory snapshot during execution"
  },
  "program_output": {
    "seed": "0x123456789abcdef...",
    "dice_values": [1, 4, 2, 6, 3, 5],
    "roll_index": 42
  },
  "verification_data": {
    "program_hash": "0xabc123...",
    "output_hash": "0xdef456..."
  }
}
```

#### B. Verification Process
1. **Artifact Retrieval**: Download artifacts from IPFS using published URI
2. **Program Verification**: Verify the Cairo program hash matches expected
3. **Execution Verification**: Use Cairo tooling to verify execution trace
4. **Output Verification**: Confirm dice values match program outputs
5. **Deterministic Check**: Re-run program with same seed to verify reproducibility

### 3. Cairo Integration Service

#### A. Dice Generation Service

```rust
// Pseudo-code for Cairo integration service
pub struct CairoDiceService {
    cairo_runner: CairoRunner,
    game_seeds: HashMap<RoomId, GameSeed>,
    storage: DecentralizedStorage,
}

pub struct GameSeed {
    seed: FieldElement,
    commitment: FieldElement,
    room_id: RoomId,
    created_at: DateTime<Utc>,
}

impl CairoDiceService {
    pub async fn generate_game_commitment(&self, room_id: RoomId) -> Result<GameCommitment> {
        let seed = self.generate_secure_seed();
        let commitment = self.compute_commitment(seed);
        
        // Store game seed for later revelation
        self.game_seeds.insert(room_id, GameSeed {
            seed,
            commitment,
            room_id,
            created_at: Utc::now(),
        });
        
        Ok(GameCommitment { 
            commitment_hash: commitment,
            room_id 
        })
    }
    
    pub async fn generate_game_artifacts(&self, room_id: RoomId, total_rolls: u32) -> Result<GameArtifacts> {
        let game_seed = self.game_seeds.get(&room_id)
            .ok_or("No seed found for room")?;
        
        // Generate all dice values for the entire game using Cairo
        let all_dice_values = self.cairo_runner.run_dice_roller(
            game_seed.seed,
            total_rolls * 6, // 6 dice per roll
            0 // Start from index 0
        ).await?;
        
        // Generate comprehensive proof artifacts for entire game
        let artifacts = self.cairo_runner.generate_full_game_artifacts(
            game_seed.seed,
            &all_dice_values,
            total_rolls
        ).await?;
        
        // Store artifacts to IPFS/decentralized storage
        let artifact_uri = self.storage.store_game_artifacts(&artifacts).await?;
        
        Ok(GameArtifacts {
            seed: game_seed.seed,
            total_rolls,
            dice_values: all_dice_values,
            artifact_uri,
            artifacts, // For immediate verification
        })
    }
    
    pub async fn reveal_game_seed(&self, room_id: RoomId) -> Result<SeedReveal> {
        let game_seed = self.game_seeds.get(&room_id)
            .ok_or("No seed found for room")?;
        
        Ok(SeedReveal {
            seed: game_seed.seed,
            commitment: game_seed.commitment,
        })
    }
}
```

#### B. Frontend Integration

```typescript
// Frontend service for Cairo dice integration
export class CairoDiceService {
    private ws: WebSocket;
    private cairoService: string;
    
    async createGameWithCommitment(roomId: string): Promise<string> {
        // Request commitment for entire game from Cairo service
        const response = await fetch(`${this.cairoService}/game/commit`, {
            method: 'POST',
            body: JSON.stringify({ roomId }),
        });
        
        const { commitment } = await response.json();
        
        // Initialize game contract with commitment
        const tx = await this.gameContract.initializeWithCommitment(
            this.roomAddress,
            this.players,
            commitment
        );
        await tx.wait();
        
        return commitment;
    }
    
    async endGameAndReveal(roomId: string): Promise<GameReveal> {
        // Generate complete game artifacts
        const rollCount = await this.gameContract.getCurrentRollIndex();
        
        const artifactsResponse = await fetch(`${this.cairoService}/game/artifacts`, {
            method: 'POST',
            body: JSON.stringify({ roomId, totalRolls: rollCount }),
        });
        
        const { seed, artifactUri, artifacts } = await artifactsResponse.json();
        
        // Reveal seed and publish artifacts
        const tx = await this.gameContract.revealGameSeed(seed, artifactUri);
        await tx.wait();
        
        // Store complete game artifacts locally for verification
        await this.storeGameArtifacts(roomId, artifacts);
        
        return { seed, artifactUri, artifacts, totalRolls: rollCount };
    }
    
    async verifyEntireGame(roomId: string): Promise<GameVerification> {
        // Get game commitment and revealed seed
        const { commitment, seed, artifactURI } = await this.gameContract.getGameCommitment();
        
        if (!seed || seed === '0x0000000000000000000000000000000000000000000000000000000000000000') {
            throw new Error('Game seed not yet revealed');
        }
        
        // Download and verify complete game artifacts
        const artifacts = await this.downloadGameArtifacts(artifactURI);
        const rollCount = await this.gameContract.getCurrentRollIndex();
        
        return this.cairoVerifier.verifyFullGame(seed, commitment, artifacts, rollCount);
    }
}
```

### 3. Enhanced Game Flow

#### A. Modified Roll Sequence

```
=== GAME SETUP ===
1. Room is created
   ↓
2. Cairo service generates master seed and commitment hash
   ↓
3. Game contract initialized with commitment (publicly visible)
   ↓
4. Players can see commitment but not the seed

=== DURING GAMEPLAY ===
5. Player clicks "Roll Dice"
   ↓
6. Smart contract generates dice using roll index + commitment
   ↓
7. Game continues with deterministic dice values
   ↓
8. All rolls use same master seed with incremental indices

=== GAME END ===
9. Game concludes (winner determined)
   ↓
10. Cairo service generates complete game artifacts
   ↓
11. Master seed revealed and artifacts published to IPFS
   ↓
12. Players can verify entire game's fairness using Cairo tooling
   ↓
13. All dice rolls throughout game are provably fair and verifiable
```

#### B. User Experience Considerations

- **Transparency**: Display commitment hashes to players
- **Verification**: Provide tools for players to verify dice fairness
- **Performance**: Maintain current game speed despite added complexity
- **Fallback**: Implement graceful degradation if Cairo service is unavailable

## Implementation Phases

### Phase 1: Core Infrastructure (Weeks 1-3)
- [ ] Modify smart contract with game-level commitment system
- [ ] Implement Cairo dice service for room-based seed generation
- [ ] Create artifact generation and storage system
- [ ] Add game commitment and seed revelation functions

### Phase 2: Frontend Integration (Weeks 4-5)
- [ ] Update UI to show game commitment at room creation
- [ ] Add post-game verification tools and interface
- [ ] Implement seed revelation flow for completed games
- [ ] Add fairness transparency dashboard

### Phase 3: Testing & Optimization (Weeks 6-7)
- [ ] Comprehensive testing with complete game verification
- [ ] Performance optimization for artifact generation
- [ ] Security audit of game-level commitment scheme
- [ ] Gas cost optimization for commitment storage

### Phase 4: Production Deployment (Week 8)
- [ ] Deploy updated smart contracts
- [ ] Launch Cairo dice service
- [ ] Monitor system performance
- [ ] Gather user feedback

## Security Considerations

### 1. Commit-Reveal Security
- **Commitment Binding**: Ensure game commitment cannot be changed after room creation
- **Seed Protection**: Secure storage of master seed until game completion
- **Artifact Publication**: Require publication of verification artifacts after game ends
- **Replay Protection**: Prevent reuse of seeds across different games

### 2. Cairo Proof Integrity
- **Artifact Authenticity**: Ensure Cairo artifacts are tamper-proof and verifiable
- **Seed Generation**: Use cryptographically secure random number generation
- **Hash Chain Integrity**: Ensure proper Pedersen hash implementation
- **Deterministic Verification**: Allow anyone to verify dice fairness using Cairo tooling
- **Artifact Storage**: Use decentralized storage (IPFS) to prevent artifact manipulation

### 3. Game State Protection
- **Atomic Operations**: Ensure commit-reveal operations are atomic
- **State Consistency**: Maintain game state integrity during proof failures
- **Access Control**: Restrict commitment/reveal functions to current player
- **Timing Attacks**: Prevent timing-based manipulation of randomness

## Performance Considerations

### 1. Gas Optimization
- **Batch Operations**: Combine multiple dice operations where possible
- **Efficient Storage**: Maintain current packed dice storage format
- **Artifact Size**: Optimize Cairo artifact storage and retrieval
- **Fallback Mechanisms**: Implement efficient fallback to current system

### 2. Latency Management
- **Async Processing**: Use WebSocket connections for real-time updates
- **Artifact Caching**: Cache frequently accessed artifacts locally
- **Parallel Processing**: Generate artifacts in parallel with game actions
- **Progressive Enhancement**: Show intermediate states while proofs generate

## Monitoring & Analytics

### 1. Fairness Metrics
- **Distribution Analysis**: Monitor dice roll distributions for fairness
- **Bias Detection**: Implement statistical tests for randomness bias
- **Artifact Generation Rate**: Track Cairo artifact generation and storage success rates
- **Player Verification**: Monitor how often players verify dice fairness

### 2. Performance Metrics
- **Commitment Latency**: Measure time from roll request to commitment
- **Artifact Generation Time**: Track Cairo artifact generation and storage performance
- **Gas Usage**: Monitor gas consumption for new operations
- **System Availability**: Track Cairo service uptime and reliability

## Future Enhancements

### 1. Advanced Verification
- **Client-Side Verification**: Allow players to verify artifacts using local Cairo tooling
- **Batch Verification**: Verify multiple dice rolls using batch artifact processing
- **Historical Auditing**: Provide tools to audit past game fairness
- **Cross-Chain Compatibility**: Extend to other blockchain networks

### 2. Enhanced User Experience
- **Fairness Dashboard**: Show player-specific fairness statistics
- **Artifact Explorer**: Allow detailed examination of Cairo execution artifacts
- **Automated Verification**: Implement automatic fairness checking
- **Educational Content**: Provide materials explaining provable fairness

## Conclusion

The integration of the Cairo dice roller into the Farkle game will provide:

1. **Provable Fairness**: Players can verify the fairness of every dice roll
2. **Transparency**: Complete auditability of randomness generation
3. **Security**: Cryptographically sound randomness without relying on block variables
4. **Trust**: Increased player confidence in game integrity
5. **Innovation**: Cutting-edge use of Cairo proving technology in gaming

The hybrid architecture maintains the existing game performance while adding the security and transparency benefits of provable fairness. The phased implementation approach ensures a smooth transition with minimal disruption to current gameplay.

This integration positions the Farkle game as a leader in fair gaming technology, providing players with unprecedented transparency and verifiability in dice-based gaming. 