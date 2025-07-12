// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IFarkleRoom} from '../interface/IFarkleRoom.sol';
import {Ownable} from '@solady/auth/Ownable.sol';
import {Initializable} from '@solady/utils/Initializable.sol';
import {IFarkleGameFactory} from '@interface/IFarkleGameFactory.sol';

contract FarkleRoomImpl is IFarkleRoom, Ownable, Initializable {
	string public constant VERSION = 'v1';
	uint256 public maxPlayers;
	address[] public players;
	uint256 public entryFee;
	IFarkleGameFactory public gameFactory;

	error AlreadyJoined();
	error AlreadyLeft();
	error RoomFull();
	error InvalidFactory();

	constructor() {
		_disableInitializers();
	}

	function initialize(uint256 _maxPlayers, address _gameFactory) external override initializer {
		if (_gameFactory == address(0) || _gameFactory.code.length == 0) {
			revert InvalidFactory();
		}
		_initializeOwner(msg.sender);
		maxPlayers = _maxPlayers;
		gameFactory = IFarkleGameFactory(_gameFactory);
	}

	function join() external override {
		if (players.length >= maxPlayers) {
			revert RoomFull();
		}
		for (uint256 i = 0; i < players.length; i++) {
			if (players[i] == msg.sender) {
				revert AlreadyJoined();
			}
		}
		players.push(msg.sender);
		emit PlayerJoined(msg.sender);
	}

	function leave() external override {
		for (uint256 i = 0; i < players.length; i++) {
			if (players[i] == msg.sender) {
				players[i] = players[players.length - 1];
				players.pop();
				emit PlayerLeft(msg.sender);
				return;
			}
		}
		revert AlreadyLeft();
	}

	function startGame() external returns (address) {
		return gameFactory.createGame(address(this), players, entryFee);
	}
}
