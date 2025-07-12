// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from '@solady/auth/Ownable.sol';
import {LibClone} from '@solady/utils/LibClone.sol';
import {IFarkleGameFactory} from '@interface/IFarkleGameFactory.sol';
import {IFarkleGame} from '@interface/IFarkleGame.sol';

contract FarkleGameFactory is IFarkleGameFactory, Ownable {
	address public immutable gameBeacon;
	address public immutable leaderboard;
	address[] public games;

	error InvalidGameBeacon();
	error InvalidLeaderboard();
	error InvalidPlayers();

	constructor(address _gameBeacon, address _leaderboard) {
		if (_gameBeacon == address(0) || _gameBeacon.code.length == 0) {
			revert InvalidGameBeacon();
		}

		if (_leaderboard == address(0) || _leaderboard.code.length == 0) {
			revert InvalidLeaderboard();
		}

		_initializeOwner(msg.sender);
		gameBeacon = _gameBeacon;
		leaderboard = _leaderboard;
	}

	function createGame(
		address room,
		address[] calldata players,
		uint256 entryFee
	) external payable returns (address) {
		// need at least 2 players, but not more than 4
		if (players.length < 2 || players.length > 4) revert InvalidPlayers();
		address game = LibClone.deployERC1967BeaconProxy(
			entryFee * players.length,
			gameBeacon,
			abi.encodeCall(IFarkleGame.initialize, (room, leaderboard, players, entryFee))
		);
		games.push(game);
		emit GameCreated(game);
		return game;
	}
}
