// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from '@solady/auth/Ownable.sol';
import {LibClone} from '@solady/utils/LibClone.sol';
import {IFarkleGameFactory} from '@interface/IFarkleGameFactory.sol';
import {IFarkleGame} from '@interface/IFarkleGame.sol';

contract FarkleGameFactory is IFarkleGameFactory, Ownable {
	address public immutable gameBeacon;
	address[] public games;

	error InvalidGameBeacon();
	error InvalidPlayers();

	constructor(address _gameBeacon) {
		if (_gameBeacon == address(0) || _gameBeacon.code.length == 0) {
			revert InvalidGameBeacon();
		}
		_initializeOwner(msg.sender);
		gameBeacon = _gameBeacon;
	}

	function createGame(
		address room,
		address[] calldata players
	) external override returns (address) {
		if (players.length == 0 || players.length > 4) revert InvalidPlayers();
		address game = LibClone.deployERC1967BeaconProxy(
			gameBeacon,
			abi.encodeCall(IFarkleGame.initialize, (room, players))
		);
		games.push(game);
		emit GameCreated(game);
		return game;
	}
}
