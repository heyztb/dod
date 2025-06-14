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
		uint48 values;
		uint8 selectedMask;
		uint8 availableCount;
	}
	DiceState public dice;

	error NotCurrentPlayer();
	error GameOver();
	error InvalidSelection();

	modifier onlyCurrentPlayer() {
		if (msg.sender != players[currentPlayer]) revert NotCurrentPlayer();
		_;
	}

	constructor() {
		_disableInitializers();
	}

	function initialize(address _room, address[] calldata _players) external initializer {
		_initializeOwner(msg.sender);
		room = _room;
		players = _players;
		for (uint256 i = 0; i < _players.length; i++) {
			playerScores[_players[i]] = 0;
		}
		dice = DiceState({values: 0, selectedMask: 0, availableCount: 6});
	}

	function roll() external override onlyCurrentPlayer {
		// TODO: Implement logic to roll the dice
		emit DiceThrown(msg.sender, dice.values);
		if (_farkle(dice.values)) {
			return;
		}
	}

	function bank(uint8 selected) external override onlyCurrentPlayer returns (uint256) {
		uint256 score = _score(selected);
		emit Banked(msg.sender, score);
		playerScores[players[currentPlayer]] += score;
		// TODO: Update dice state accordingly
		dice = DiceState({values: 0, selectedMask: 0, availableCount: 6});
		currentPlayer = (currentPlayer + 1) % players.length;
		return score;
	}

	function _score(uint8 selected) internal pure returns (uint256) {
		// TODO: Implement scoring logic
		// TODO: Revert on invalid selection
	}

	function _farkle(uint48 values) internal returns (bool) {
		// TODO: Implement logic to check for a farkle
		dice = DiceState({values: 0, selectedMask: 0, availableCount: 6});
		currentPlayer = (currentPlayer + 1) % players.length;
		emit Farkled(msg.sender);
		return true;
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
}
