// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleLeaderboardImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleLeaderboard, PlayerResult, Stats} from "src/interface/IFarkleLeaderboard.sol";
import {Initializable} from "solady/utils/Initializable.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {UUPSUpgradeable} from "solady/utils/UUPSUpgradeable.sol";
import {IFarkleGameFactory} from "src/interface/IFarkleGameFactory.sol";

contract FarkleLeaderboard is
    IFarkleLeaderboard,
    Initializable,
    Ownable,
    UUPSUpgradeable
{
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

    function update(
        PlayerResult[] calldata results,
        address token,
        uint256 pot
    ) external onlyGame {
        for (uint256 i = 0; i < results.length; i++) {
            address player = results[i].player;
            Stats storage _stats = leaderboard[player];
            _stats.gamesPlayed = _stats.gamesPlayed + 1;
            _stats.hotDiceRolled =
                _stats.hotDiceRolled +
                results[i].hotDiceCount;
            _stats.farklesRolled =
                _stats.farklesRolled +
                results[i].farkleCount;
            if (token == address(0)) {
                _stats.ethWagered = _stats.ethWagered + results[i].wager;
            } else {
                _stats.erc20Wagered[token] =
                    _stats.erc20Wagered[token] +
                    results[i].wager;
            }
            if (results[i].winner) {
                _stats.gamesWon = _stats.gamesWon + 1;
                _stats.currentWinStreak = _stats.currentWinStreak + 1;
                if (_stats.currentWinStreak > _stats.longestWinStreak) {
                    _stats.longestWinStreak = _stats.currentWinStreak;
                }
                if (pot > 0) {
                    if (token == address(0)) {
                        _stats.ethWon = _stats.ethWon + pot;
                    } else {
                        _stats.erc20Won[token] = _stats.erc20Won[token] + pot;
                    }
                }
            } else {
                _stats.currentWinStreak = 0;
            }
        }
        emit LeaderboardUpdated(token, results);
    }
}
