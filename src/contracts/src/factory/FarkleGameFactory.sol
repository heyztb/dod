// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from '@solady/auth/Ownable.sol';
import {LibClone} from '@solady/utils/LibClone.sol';
import {IFarkleGameFactory} from '@interface/IFarkleGameFactory.sol';
import {IFarkleGame} from '@interface/IFarkleGame.sol';

contract FarkleGameFactory is IFarkleGameFactory, Ownable {
	address public immutable gameBeacon;
	address public leaderboard;
	mapping(address => bool) public games;

	error InvalidGameBeacon();
	error InvalidLeaderboard();
	error InvalidPlayers();
	error DuplicatePlayer();
	error LeaderboardAlreadySet();
	error ZeroAddress();

	constructor(address _gameBeacon) {
		if (_gameBeacon == address(0) || _gameBeacon.code.length == 0) {
			revert InvalidGameBeacon();
		}

		_initializeOwner(msg.sender);
		gameBeacon = _gameBeacon;
	}

	function setLeaderboard(address _leaderboard) external onlyOwner {
		if (leaderboard != address(0)) revert LeaderboardAlreadySet();
		if (_leaderboard == address(0)) revert ZeroAddress();
		leaderboard = _leaderboard;
	}

	function createGame(
		address room,
		address[] calldata players,
		uint256 entryFee
	) external payable returns (address) {
		if (leaderboard == address(0)) revert InvalidLeaderboard();
		// need at least 2 players, but not more than 4
		if (players.length < 2 || players.length > 4) revert InvalidPlayers();
		for (uint256 i = 0; i < players.length; i++) {
			for (uint j = i + 1; j < players.length; j++) {
				if (players[i] == players[j]) {
					revert DuplicatePlayer();
				}
			}
		}
		address game = LibClone.deployERC1967BeaconProxy(
			entryFee * players.length,
			gameBeacon,
			abi.encodeCall(IFarkleGame.initialize, (room, leaderboard, players, entryFee))
		);
		games[game] = true;
		emit GameCreated(game);
		return game;
	}

	function isGame(address game) external view returns (bool) {
		return games[game];
	}
}
