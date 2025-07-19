// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleRoomFactory.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleRoomFactory} from '@interface/IFarkleRoomFactory.sol';
import {IFarkleRoom} from '@interface/IFarkleRoom.sol';
import {Ownable} from '@solady/auth/Ownable.sol';
import {LibClone} from '@solady/utils/LibClone.sol';
import {IERC20} from '@openzeppelin/token/ERC20/IERC20.sol';

contract FarkleRoomFactory is IFarkleRoomFactory, Ownable {
	address public immutable roomBeacon;
	address public gameFactory;

	error InvalidMaxPlayers();
	error InvalidToken();

	uint8 public constant MAX_PLAYERS = 4;

	constructor(address _roomBeacon, address _gameFactory) {
		_initializeOwner(msg.sender);
		roomBeacon = _roomBeacon;
		gameFactory = _gameFactory;
	}

	function createRoom(
		uint256 maxPlayers,
		address token,
		uint256 entryFee
	) external override returns (address) {
		if (maxPlayers < 2 || maxPlayers > MAX_PLAYERS) revert InvalidMaxPlayers();
		if (token != address(0) && token.code.length == 0) revert InvalidToken();
		try IERC20(token).totalSupply() returns (uint256) {} catch {
			revert InvalidToken();
		}
		address room = LibClone.deployERC1967BeaconProxy(
			roomBeacon,
			abi.encodeCall(IFarkleRoom.initialize, (maxPlayers, gameFactory, token, entryFee))
		);
		emit RoomCreated(room, maxPlayers, token, entryFee);
		return room;
	}
}
