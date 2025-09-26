// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleLeaderboardImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleLeaderboard, PlayerResult, Stats} from "src/interface/IFarkleLeaderboard.sol";
import {Initializable} from "solady/utils/Initializable.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {UUPSUpgradeable} from "solady/utils/UUPSUpgradeable.sol";
import {IFarkleGameFactory} from "src/interface/IFarkleGameFactory.sol";
import {SupportedTokens} from "src/library/Token.sol";

using SupportedTokens for SupportedTokens.Token;

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
        SupportedTokens.Token token,
        uint256 pot
    ) external onlyGame {
        for (uint256 i = 0; i < results.length; i++) {
            address player = results[i].player;
            Stats storage stats = leaderboard[player];
            stats.gamesPlayed += 1;
            stats.hotDiceRolled += results[i].hotDiceCount;
            stats.farklesRolled += results[i].farkleCount;
            if (results[i].winner) {
                stats.gamesWon += 1;
                stats.currentWinStreak += 1;

                if (stats.currentWinStreak > stats.longestWinStreak) {
                    stats.longestWinStreak = stats.currentWinStreak;
                }

                if (pot > 0) {
                    if (token.isETH()) {
                        stats.ethWagered += results[i].wager;
                        stats.ethWon += results[i].amountWon;
                    } else if (token.isUSDC()) {
                        stats.usdcWagered =
                            stats.usdcWagered +
                            results[i].wager;
                        stats.usdcWon += results[i].amountWon;
                    }
                }
            } else {
                stats.currentWinStreak = 0;
                if (pot > 0) {
                    if (token.isETH()) {
                        stats.ethWagered += results[i].wager;
                    } else if (token.isUSDC()) {
                        stats.usdcWagered += results[i].wager;
                    }
                }
            }
        }
        emit LeaderboardUpdated(token, results);
    }
}
