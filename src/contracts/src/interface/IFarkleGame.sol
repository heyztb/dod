// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGame {
	function roll() external;

	function bank(uint8 selected) external returns (uint256);

	event DiceThrown(address indexed player, uint48 values);
	event Farkled(address indexed player);
	event Banked(address indexed player, uint256 score);
}
