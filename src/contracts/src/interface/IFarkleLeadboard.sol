// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.30;

interface IFarkleLeaderboard {
	function update(address[] calldata players) external;
}
