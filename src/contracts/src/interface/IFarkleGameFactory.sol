// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGameFactory {
	function createGame() external returns (address);

	event GameCreated(uint256 indexed gameId, address indexed game);
}
