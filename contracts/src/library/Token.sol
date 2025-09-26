// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library SupportedTokens {
    enum Token {
        ETH,
        USDC
    }

    function isETH(Token token) internal pure returns (bool) {
        return token == Token.ETH;
    }

    function isUSDC(Token token) internal pure returns (bool) {
        return token == Token.USDC;
    }
}
