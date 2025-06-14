// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IFarkleRoom} from '../interface/IFarkleRoom.sol';
import {Ownable} from '@solady/auth/Ownable.sol';
import {Initializable} from '@solady/utils/Initializable.sol';

contract FarkleRoomImpl is IFarkleRoom, Ownable, Initializable {
	string public constant VERSION = 'v1';
	uint256 public maxPlayers;
	address[] public players;

	error AlreadyJoined();
	error AlreadyLeft();
	error RoomFull();

	constructor() {
		_disableInitializers();
	}

	function initialize(uint256 _maxPlayers) external override initializer {
		_initializeOwner(msg.sender);
		maxPlayers = _maxPlayers;
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
			}
		}
		revert AlreadyLeft();
	}
}
