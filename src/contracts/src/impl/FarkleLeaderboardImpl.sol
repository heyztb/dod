// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.30;

import {IFarkleLeaderboard, PlayerResult, Stats} from '@interface/IFarkleLeaderboard.sol';
import {Initializable} from '@solady/utils/Initializable.sol';
import {Ownable} from '@solady/auth/Ownable.sol';

contract FarkleLeaderboard is IFarkleLeaderboard, Initializable, Ownable {
	mapping(address => Stats) public leaderboard;

	constructor() {
		_disableInitializers();
	}

	function initialize() public initializer {
		_initializeOwner(msg.sender);
	}

	// TODO: Update function signature to accept player and stats
	function update(PlayerResult[] calldata results) external onlyOwner {
		uint256 totalWager = 0;
		for (uint256 i = 0; i < results.length; i++) {
			totalWager = totalWager + results[i].wager;
		}

		for (uint256 i = 0; i < results.length; i++) {
			address player = results[i].player;
			Stats storage _stats = leaderboard[player];
			_stats.gamesPlayed = _stats.gamesPlayed + 1;
			_stats.hotDiceRolled = _stats.hotDiceRolled + results[i].hotDiceCount;
			_stats.farklesRolled = _stats.farklesRolled + results[i].farkleCount;
			_stats.totalWagered = _stats.totalWagered + results[i].wager;
			if (results[i].winner) {
				_stats.gamesWon = _stats.gamesWon + 1;
				_stats.currentWinStreak = _stats.currentWinStreak + 1;
				if (_stats.currentWinStreak > _stats.longestWinStreak) {
					_stats.longestWinStreak = _stats.currentWinStreak;
				}
				_stats.totalWon = _stats.totalWon + totalWager;
			} else {
				_stats.currentWinStreak = 0;
			}
		}
		emit LeaderboardUpdated(results);
	}
}
