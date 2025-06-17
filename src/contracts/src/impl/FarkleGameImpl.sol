// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from '@solady/auth/Ownable.sol';
import {Initializable} from '@solady/utils/Initializable.sol';
import {IFarkleGame} from '@interface/IFarkleGame.sol';

contract FarkleGameImpl is IFarkleGame, Ownable, Initializable {
	string public constant VERSION = 'v1';
	address public room;
	address[] public players;
	uint256 public currentPlayer;
	mapping(address => uint256) public playerScores;

	struct DiceState {
		uint48 values; // Current dice values (1-6 each)
		uint8 selectedMask; // Bit mask for selected dice (1 = selected, 0 = available)
		uint8 availableCount; // Number of dice available to roll
		uint32 turnScore; // Points accumulated this turn
		bool hasRolled; // Whether player has rolled this turn
	}

	DiceState public dice;

	error NotCurrentPlayer();
	error GameOver();
	error InvalidSelection();
	error MustRollFirst();
	error DiceAlreadySelected();
	error NoScoringDice();

	modifier onlyCurrentPlayer() {
		if (msg.sender != players[currentPlayer]) revert NotCurrentPlayer();
		_;
	}

	constructor() {
		_disableInitializers();
	}

	function initialize(address _room, address[] calldata _players) external virtual initializer {
		_initializeOwner(msg.sender);
		room = _room;
		players = _players;
		for (uint256 i = 0; i < _players.length; i++) {
			playerScores[_players[i]] = 0;
		}
		dice = DiceState({
			values: 0,
			selectedMask: 0,
			availableCount: 6,
			turnScore: 0,
			hasRolled: false
		});
	}

	function roll() external override onlyCurrentPlayer {
		require(dice.availableCount > 0, 'No dice available to roll');

		// Generate new dice values, preserving selected dice
		uint8[6] memory newValues = _rollAvailableDice();
		dice.values = _packDiceValues(newValues);
		dice.hasRolled = true;

		emit DiceThrown(msg.sender, dice.values);
		// Check for farkle (no scoring dice among the newly rolled dice)
		if (!_hasAnyScore(newValues)) {
			_farkle();
		}
	}

	function bank(uint8[] calldata selectedIndices) external onlyCurrentPlayer returns (uint256) {
		require(dice.hasRolled, 'Must roll first');
		require(selectedIndices.length > 0, 'Must select at least one die');

		// Validate selections
		uint8[6] memory currentValues = _unpackDiceValues(dice.values);
		for (uint256 i = 0; i < selectedIndices.length; i++) {
			uint8 index = selectedIndices[i];
			require(index < 6, 'Invalid die index');
			require((dice.selectedMask & (1 << index)) == 0, 'Die already selected');
		}

		// Calculate score for this selection
		uint256 score = _calculateSelectionScore(selectedIndices, currentValues);
		require(score > 0, 'Selection must score points');

		// Update state
		dice.turnScore += uint32(score);

		// Mark dice as selected
		for (uint256 i = 0; i < selectedIndices.length; i++) {
			dice.selectedMask |= uint8(1 << selectedIndices[i]);
		}

		// Update available count
		dice.availableCount -= uint8(selectedIndices.length);

		// Check for hot dice (all 6 dice selected)
		if (dice.availableCount == 0) {
			// Hot dice! Reset for another roll with all 6 dice
			dice.selectedMask = 0;
			dice.availableCount = 6;
			dice.hasRolled = false; // Player must roll again
		}

		emit Banked(msg.sender, score);
		return score;
	}

	function endTurn() external onlyCurrentPlayer {
		require(dice.hasRolled, 'Must roll at least once');

		// Bank the turn score
		playerScores[players[currentPlayer]] += dice.turnScore;

		// Reset for next player
		_nextTurn();
	}

	function _rollAvailableDice() internal view returns (uint8[6] memory) {
		uint8[6] memory values = _unpackDiceValues(dice.values);
		uint256 seed = uint256(
			keccak256(
				abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, dice.turnScore)
			)
		);

		// Only roll unselected dice
		for (uint256 i = 0; i < 6; i++) {
			if ((dice.selectedMask & (1 << i)) == 0) {
				// This die is not selected, roll it
				values[i] = uint8((seed >> (i * 8)) % 6) + 1;
			}
			// Selected dice keep their existing values
		}

		return values;
	}

	function _calculateSelectionScore(
		uint8[] calldata indices,
		uint8[6] memory values
	) internal pure returns (uint256) {
		// Count frequencies of selected dice values
		uint8[7] memory counts; // index 0 unused, 1-6 for die values

		for (uint256 i = 0; i < indices.length; i++) {
			uint8 value = values[indices[i]];
			counts[value]++;
		}

		return _scoreFromCounts(counts);
	}

	function _scoreFromCounts(uint8[7] memory counts) internal pure returns (uint256) {
		uint256 score = 0;

		// Check for special combinations first (highest priority)

		// Check for straight (1,2,3,4,5,6) = 1500 points
		if (
			counts[1] == 1 &&
			counts[2] == 1 &&
			counts[3] == 1 &&
			counts[4] == 1 &&
			counts[5] == 1 &&
			counts[6] == 1
		) {
			return 1500;
		}

		// Check for two sets of three of a kind = 2500 points
		uint8 threeOfAKindCount = 0;
		for (uint8 value = 1; value <= 6; value++) {
			if (counts[value] == 3) {
				threeOfAKindCount++;
			}
		}
		if (threeOfAKindCount == 2) {
			return 2500;
		}

		// Check for three pairs = 1500 points
		uint8 pairCount = 0;
		for (uint8 value = 1; value <= 6; value++) {
			if (counts[value] == 2) {
				pairCount++;
			}
		}
		if (pairCount == 3) {
			return 1500;
		}

		// Check for four of a kind + pair = 1500 points
		bool hasFourOfAKind = false;
		bool hasPair = false;
		for (uint8 value = 1; value <= 6; value++) {
			if (counts[value] == 4) {
				hasFourOfAKind = true;
			} else if (counts[value] == 2) {
				hasPair = true;
			}
		}
		if (hasFourOfAKind && hasPair) {
			return 1500;
		}

		// Standard scoring for individual combinations
		for (uint8 value = 1; value <= 6; value++) {
			uint8 count = counts[value];
			if (count == 0) continue;

			if (count == 6) {
				// 6 of a kind = 3000 points
				score += 3000;
			} else if (count == 5) {
				// 5 of a kind = 2000 points
				score += 2000;
			} else if (count == 4) {
				// 4 of a kind = 1000 points
				score += 1000;
			} else if (count == 3) {
				// Three of a kind
				if (value == 1) {
					score += 1000; // Three 1s = 1000
				} else {
					score += uint256(value) * 100; // Three of anything else = face value × 100
				}
			} else {
				// Individual dice (1s and 5s only)
				if (value == 1) {
					score += uint256(count) * 100; // Individual 1s = 100 each
				} else if (value == 5) {
					score += uint256(count) * 50; // Individual 5s = 50 each
				}
				// Note: Individual 2s, 3s, 4s, 6s don't score unless part of combinations
			}
		}

		return score;
	}

	function _hasAnyScore(uint8[6] memory values) internal view returns (bool) {
		// Check only the newly rolled dice (unselected ones)
		uint8[7] memory counts;
		uint8 newDiceCount = 0;

		for (uint256 i = 0; i < 6; i++) {
			if ((dice.selectedMask & (1 << i)) == 0) {
				// This die was just rolled
				counts[values[i]]++;
				newDiceCount++;
			}
		}

		// Check if any of the newly rolled dice can score
		for (uint8 value = 1; value <= 6; value++) {
			if (counts[value] >= 3) return true; // Three of a kind
			if (value == 1 && counts[1] > 0) return true; // Individual 1s
			if (value == 5 && counts[5] > 0) return true; // Individual 5s
		}

		return false;
	}

	function _farkle() internal {
		// Farkle! Lose all turn points and end turn
		emit Farkled(msg.sender);
		_nextTurn();
	}

	function _nextTurn() internal {
		// Reset dice state for next player
		dice = DiceState({
			values: 0,
			selectedMask: 0,
			availableCount: 6,
			turnScore: 0,
			hasRolled: false
		});

		// Move to next player
		currentPlayer = (currentPlayer + 1) % players.length;
	}

	function _packDiceValues(uint8[6] memory values) internal pure returns (uint48) {
		uint48 packed = 0;
		for (uint48 i = 0; i < 6; i++) {
			packed |= uint48(values[i] - 1) << (i * 8);
		}
		return packed;
	}

	function _unpackDiceValues(uint48 packed) internal pure returns (uint8[6] memory) {
		uint8[6] memory values;
		for (uint8 i = 0; i < 6; i++) {
			values[i] = uint8(((packed >> (i * 8)) & 0xFF) + 1);
		}
		return values;
	}

	// View functions for game state
	function getCurrentDiceValues() external view returns (uint8[6] memory) {
		return _unpackDiceValues(dice.values);
	}

	function getSelectedMask() external view returns (uint8) {
		return dice.selectedMask;
	}

	function getTurnScore() external view returns (uint32) {
		return dice.turnScore;
	}

	function getAvailableCount() external view returns (uint8) {
		return dice.availableCount;
	}
}
