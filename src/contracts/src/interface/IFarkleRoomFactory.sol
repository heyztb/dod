// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleRoomFactory {
	function createRoom(uint256 maxPlayers) external returns (address);

	event RoomCreated(address indexed room, uint256 indexed maxPlayers);
}
