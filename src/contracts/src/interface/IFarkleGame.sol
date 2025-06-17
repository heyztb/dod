// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGame {
	// Core game functions
	function roll() external;

	function selectDice(uint8[] calldata selectedIndices) external returns (uint256);

	function bank() external;

	// Events
	event DiceThrown(address indexed player, uint48 values);
	event DiceSelected(address indexed player, uint256 score);
	event Banked(address indexed player, uint256 totalScore);
	event Farkled(address indexed player);
}
