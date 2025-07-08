// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.30;

import {IFarkleLeaderboard} from '@interface/IFarkleLeadboard.sol';
import {Initializable} from '@solady/utils/Initializable.sol';
import {Ownable} from '@solady/auth/Ownable.sol';

contract FarkleLeaderboard is IFarkleLeaderboard, Initializable, Ownable {
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

	mapping(address => Stats) public leaderboard;

	constructor() {
		_disableInitializers();
	}

	function initialize() public initializer {
		_initializeOwner(msg.sender);
	}

	event LeaderboardUpdated();

	// TODO: Update function signature to accept player and stats
	function update(address[] calldata players) external override onlyOwner {
		for (uint256 i = 0; i < players.length; i++) {
			Stats storage stats = leaderboard[players[i]];
			stats.gamesPlayed = stats.gamesPlayed + 1;
		}
		// TODO: Add logic
		emit LeaderboardUpdated();
	}

	function _checkWinStreak() internal {}

	function _updateLeaderboard() internal {}
}
