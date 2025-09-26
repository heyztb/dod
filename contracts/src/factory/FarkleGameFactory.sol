// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleGameFactory.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {Ownable} from "solady/auth/Ownable.sol";
import {LibClone} from "solady/utils/LibClone.sol";
import {IFarkleGameFactory} from "src/interface/IFarkleGameFactory.sol";
import {IFarkleGame} from "src/interface/IFarkleGame.sol";
import {SupportedTokens} from "src/library/Token.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

using SupportedTokens for SupportedTokens.Token;

contract FarkleGameFactory is IFarkleGameFactory, Ownable {
    address public constant usdc =
        address(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    address public immutable gameBeacon;
    mapping(address => bool) public games;

    event GameCreated(address indexed game);

    error InvalidPlayers();

    constructor(address _gameBeacon) {
        _initializeOwner(msg.sender);
        gameBeacon = _gameBeacon;
    }

    function createGame(
        SupportedTokens.Token token,
        uint256 entryFee
    ) external returns (address) {
        address game = LibClone.deployERC1967BeaconProxy(
            gameBeacon,
            abi.encodeCall(IFarkleGame.initialize, (token, entryFee))
        );
        games[game] = true;
        emit GameCreated(game);
        return game;
    }

    function isGame(address game) external view returns (bool) {
        return games[game];
    }
}
