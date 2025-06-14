// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleRoom {
	function initialize(uint256 maxPlayers) external;

	function join() external;

	function leave() external;

	event PlayerJoined(address indexed player);
	event PlayerLeft(address indexed player);
	event RoomClosed();
}
