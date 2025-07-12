// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGameFactory {
	function createGame(
		address room,
		address[] calldata players,
		uint256 entryFee
	) external payable returns (address);

	event GameCreated(address indexed game);
}
