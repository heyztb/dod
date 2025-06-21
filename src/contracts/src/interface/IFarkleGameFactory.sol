// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGameFactory {
	function createGame(address room, address[] calldata players) external returns (address);

	event GameCreated(address indexed game);
}
