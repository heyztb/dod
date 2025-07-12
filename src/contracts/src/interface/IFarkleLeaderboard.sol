// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.30;

struct Stats {
	uint256 gamesPlayed;
	uint256 gamesWon;
	uint256 totalWagered;
	uint256 totalWon;
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
	event LeaderboardUpdated(address[] players);

	function update(PlayerResult[] calldata results) external;
}
