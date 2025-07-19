// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleLeaderboardImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleLeaderboard, PlayerResult, Stats} from '@interface/IFarkleLeaderboard.sol';
import {Initializable} from '@solady/utils/Initializable.sol';
import {Ownable} from '@solady/auth/Ownable.sol';
import {UUPSUpgradeable} from '@solady/utils/UUPSUpgradeable.sol';
import {IFarkleGameFactory} from '@interface/IFarkleGameFactory.sol';

contract FarkleLeaderboard is IFarkleLeaderboard, Initializable, Ownable, UUPSUpgradeable {
	mapping(address => Stats) public leaderboard;
	IFarkleGameFactory public gameFactory;

	error NotGame();

	modifier onlyGame() {
		if (!gameFactory.isGame(msg.sender)) revert NotGame();
		_;
	}

	constructor() {
		_disableInitializers();
	}

	function initialize(address _gameFactory) public initializer {
		_initializeOwner(msg.sender);
		gameFactory = IFarkleGameFactory(_gameFactory);
	}

	function _authorizeUpgrade(address) internal override onlyOwner {}

	function update(PlayerResult[] calldata results, uint256 pot) external onlyGame {
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
				_stats.totalWon = _stats.totalWon + pot;
			} else {
				_stats.currentWinStreak = 0;
			}
		}
		emit LeaderboardUpdated(results);
	}
}
