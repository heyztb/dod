// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleRoomFactory.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

interface IFarkleRoomFactory {
	function createRoom(
		uint256 maxPlayers,
		address token,
		uint256 entryFee
	) external returns (address);

	event RoomCreated(
		address indexed room,
		uint256 indexed maxPlayers,
		address token,
		uint256 entryFee
	);
}
