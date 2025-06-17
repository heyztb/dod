// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGame {
	// Core game functions
	function roll() external;

	function bank(uint8[] calldata selectedIndices) external returns (uint256);

	function endTurn() external;

	// Events
	event DiceThrown(address indexed player, uint48 values);
	event Banked(address indexed player, uint256 score);
	event Farkled(address indexed player);
}
