// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleGame.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

interface IFarkleGame {
	function initialize(
		address token,
		uint256 _entryFee
	) external;

	function join() external payable;

	function leave() external;

	function startGame() external;

	function roll() external;

	function selectDice(uint8[] calldata selectedIndices) external returns (uint256);

	function bank() external;
}
