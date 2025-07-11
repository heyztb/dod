// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.30;

import {IFarkleLeaderboard, PlayerResult, Stats} from '@interface/IFarkleLeadboard.sol';
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
		for (uint256 i = 0; i < results.length; i++) {
			address player = results[i].player;
			Stats storage _stats = leaderboard[player];
			_stats.gamesPlayed = _stats.gamesPlayed + 1;
			if (results[i].winner) {
				_stats.gamesWon = _stats.gamesWon + 1;
			}
		}
		emit LeaderboardUpdated(results);
	}
}
