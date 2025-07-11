// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFarkleGame {
	function initialize(
		address _room,
		address _leaderboard,
		address[] calldata _players,
		uint256 _entryFee
	) external;

	// Core game functions
	function roll() external;

	function selectDice(uint8[] calldata selectedIndices) external returns (uint256);

	function bank() external;
}
