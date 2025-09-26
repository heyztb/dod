// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleGame.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {SupportedTokens} from "src/library/Token.sol";

interface IFarkleGame {
    function initialize(SupportedTokens.Token token, uint256 entryFee) external;

    function join() external payable;

    function leave() external;

    function startGame() external;

    function roll() external;

    function selectDice(
        uint8[] calldata selectedIndices
    ) external returns (uint256);

    function bank() external;
}
