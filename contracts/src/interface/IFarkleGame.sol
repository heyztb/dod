// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleGame.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {SupportedTokens} from "src/library/Token.sol";

interface IFarkleGame {
    function initialize(SupportedTokens.Token token, uint256 entryFee) external;

    function join() external;

    function payEntryFee() external payable;

    function leave() external;

    function withdrawRefund() external;

    function withdrawWinnings() external;

    function startGame() external;

    function roll() external;

    function selectDice(
        uint8[] calldata selectedIndices
    ) external returns (uint256);

    function bank() external;

    function getCurrentDiceValues() external view returns (uint8[6] memory);

    function getSelectedMask() external view returns (uint8);

    function getTurnScore() external view returns (uint32);

    function getAvailableCount() external view returns (uint8);
}
