// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleGameFactory.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

interface IFarkleGameFactory {
	function createGame(
		address room,
		address[] calldata players,
		address token,
		uint256 entryFee
	) external payable returns (address);

	function isGame(address game) external view returns (bool);

	event GameCreated(address indexed game);
}
