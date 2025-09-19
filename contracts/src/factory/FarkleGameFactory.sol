// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleGameFactory.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {Ownable} from "solady/auth/Ownable.sol";
import {LibClone} from "solady/utils/LibClone.sol";
import {IFarkleGameFactory} from "src/interface/IFarkleGameFactory.sol";
import {IFarkleGame} from "src/interface/IFarkleGame.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract FarkleGameFactory is IFarkleGameFactory, Ownable {
    address public immutable gameBeacon;
    mapping(address => bool) public games;

    event GameCreated(address indexed game);

    error InvalidERC20TokenAddress();
    error InvalidPlayers();

    constructor(address _gameBeacon) {
        _initializeOwner(msg.sender);
        gameBeacon = _gameBeacon;
    }

    function createGame(
        address token,
        uint256 entryFee
    ) external returns (address) {
        if (token != address(0)) {
            if (token.code.length == 0) revert InvalidERC20TokenAddress();
            try IERC20(token).totalSupply() returns (uint256) {
                // do nothing, just checking that the token address at least looks like an ERC20
            } catch {
                revert InvalidERC20TokenAddress();
            }
        }

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
