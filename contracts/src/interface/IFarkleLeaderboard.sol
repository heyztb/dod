// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleLeaderboard.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {SupportedTokens} from "src/library/Token.sol";

struct Stats {
    uint256 gamesPlayed;
    uint256 gamesWon;
    uint256 ethWagered;
    uint256 ethWon;
    uint256 usdcWagered;
    uint256 usdcWon;
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
    uint256 amountWon;
}

interface IFarkleLeaderboard {
    event LeaderboardUpdated(
        SupportedTokens.Token token,
        PlayerResult[] results
    );

    function update(
        PlayerResult[] calldata results,
        SupportedTokens.Token token,
        uint256 pot
    ) external;
}
