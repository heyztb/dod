// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleLeaderboard.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

struct Stats {
	uint256 gamesPlayed;
	uint256 gamesWon;
	uint256 ethWagered;
	uint256 ethWon;
	mapping(address => uint256) erc20Wagered;
	mapping(address => uint256) erc20Won;
	uint256 longestWinStreak;
	uint256 currentWinStreak;
	uint256 farklesRolled;
	uint256 hotDiceRolled;
}

struct PlayerResult {
	address player;
	bool winner;
	uint256 farkleCount;
	uint256 hotDiceCount;
	uint256 wager;
}

interface IFarkleLeaderboard {
	event LeaderboardUpdated(address token, PlayerResult[] results);

	function update(PlayerResult[] calldata results, address token, uint256 pot) external;
}
