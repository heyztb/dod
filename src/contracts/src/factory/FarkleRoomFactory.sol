// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IFarkleRoomFactory} from '@interface/IFarkleRoomFactory.sol';
import {IFarkleRoom} from '@interface/IFarkleRoom.sol';
import {Ownable} from '@solady/auth/Ownable.sol';
import {LibClone} from '@solady/utils/LibClone.sol';

contract FarkleRoomFactory is IFarkleRoomFactory, Ownable {
	address public immutable roomBeacon;

	constructor(address _roomBeacon) {
		_initializeOwner(msg.sender);
		roomBeacon = _roomBeacon;
	}

	function createRoom(uint256 maxPlayers) external override returns (address) {
		address room = LibClone.deployERC1967BeaconProxy(
			roomBeacon,
			abi.encodeCall(IFarkleRoom.initialize, (maxPlayers))
		);
		emit RoomCreated(room, maxPlayers);
		return room;
	}
}
