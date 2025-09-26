// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleGameFactory.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {SupportedTokens} from "src/library/Token.sol";

interface IFarkleGameFactory {
    function createGame(
        SupportedTokens.Token token,
        uint256 entryFee
    ) external returns (address);

    function isGame(address game) external view returns (bool);
}
