// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleRoomImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleRoom} from "src/interface/IFarkleRoom.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {Initializable} from "solady/utils/Initializable.sol";
import {IFarkleGameFactory} from "src/interface/IFarkleGameFactory.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract FarkleRoomImpl is IFarkleRoom, Ownable, Initializable {
    string public constant VERSION = "v1";
    uint256 public maxPlayers;
    address[] public players;
    address public token; // if (token == address(0)) then ETH else ERC20
    uint256 public entryFee;
    bool public open;
    IFarkleGameFactory public gameFactory;

    event PlayerJoined(address indexed player);
    event PlayerLeft(address indexed player);
    event ClosingRoom();
    event GameStarted(address indexed game);

    error AlreadyJoined();
    error NotInRoom();
    error RoomFull();
    error RoomClosed();
    error InvalidFactory();
    error InvalidMaxPlayers();
    error InvalidToken();

    modifier onlyWhileOpen() {
        if (!open) revert RoomClosed();
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 _maxPlayers,
        address _gameFactory,
        address _token,
        uint256 _entryFee
    ) external override initializer {
        if (_maxPlayers < 2 || _maxPlayers > 4) revert InvalidMaxPlayers();
        if (_gameFactory == address(0) || _gameFactory.code.length == 0) {
            revert InvalidFactory();
        }
        if (_token != address(0) && _token.code.length == 0) {
            revert InvalidToken();
        }
        open = true;
        maxPlayers = _maxPlayers;
        gameFactory = IFarkleGameFactory(_gameFactory);
        token = _token;
        entryFee = _entryFee;
        transferOwnership(address(0));
    }

    function join() external override onlyWhileOpen {
        if (players.length >= maxPlayers) {
            revert RoomFull();
        }
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                revert AlreadyJoined();
            }
        }
        players.push(msg.sender);
        emit PlayerJoined(msg.sender);
    }

    function leave() external override {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                players[i] = players[players.length - 1];
                players.pop();
                emit PlayerLeft(msg.sender);
                if (players.length == 0) {
                    open = false;
                    emit ClosingRoom();
                }
                return;
            }
        }
        revert NotInRoom();
    }

    function startGame() external returns (address) {
        open = false;
        address game = gameFactory.createGame(
            address(this),
            players,
            token,
            entryFee
        );
        emit GameStarted(game);
        return game;
    }
}
