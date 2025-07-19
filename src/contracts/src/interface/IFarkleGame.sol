// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleGame.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

interface IFarkleGame {
	function initialize(
		address _room,
		address _leaderboard,
		address[] calldata _players,
		address token,
		uint256 _entryFee
	) external payable;

	// Core game functions
	function roll() external;

	function selectDice(uint8[] calldata selectedIndices) external returns (uint256);

	function bank() external;
}
