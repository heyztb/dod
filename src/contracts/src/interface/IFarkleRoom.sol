// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleRoom.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

interface IFarkleRoom {
	function initialize(
		uint256 maxPlayers,
		address _gameFactory,
		address _token,
		uint256 _entryFee
	) external;

	function join() external;

	function leave() external;

	function startGame() external returns (address);
}
