// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {LibClone} from "solady/utils/LibClone.sol";

import {FarkleGameImpl} from "src/impl/FarkleGameImpl.sol";

import {FarkleGameFactory} from "../src/factory/FarkleGameFactory.sol";
import {FarkleLeaderboard} from "../src/impl/FarkleLeaderboardImpl.sol";

contract Deploy is Script {
    address constant EGL_MSIG = 0x6052F75B3FbDd4A89d6a0E4Be7119Db18ea20a35;
    bytes constant BEACON_BYTECODE =
        hex"60406101ce3d393d5160205180821760a01c3d3d3e803b1560875781684343a0dc92ed22dbfc558068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a23d7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3610139806100953d393df35b636d3e283b3d526004601cfdfe3d3560e01c635c60da1b14610127573d3560e01c80638da5cb5b146101155780633659cfe61460021b8163f2fde38b1460011b179063715018a6141780153d3d3e684343a0dc92ed22dbfc54803303610108573d9160068116610090575b5081684343a0dc92ed22dbfc557f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3005b915060048035928360a01c60243610173d3d3e146100c15781156100b4575f61005d565b637448fbae3d526004601cfd5b50803b156100fb578068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a2005b636d3e283b3d526004601cfd5b6382b429003d526004601cfd5b684343a0dc92ed22dbfc543d5260203df35b68911c5a209f08d5ec5e543d5260203df3";

    function run(address vrfCoordinator) external {
        require(vrfCoordinator != address(0), "vrfCoordinator required");

        vm.startBroadcast();

        // 3) Deploy FarkleGame implementation + beacon
        FarkleGameImpl gameImpl = new FarkleGameImpl(vrfCoordinator);
        console.log("FarkleGameImpl deployed at:", address(gameImpl));
        address gameBeacon = deployBeacon(
            EGL_MSIG,
            address(gameImpl),
            "FarkleGameBeacon"
        );
        console.log("FarkleGame beacon at:", gameBeacon);

        // 4) Deploy Factory (needs game beacon address)
        FarkleGameFactory factory = new FarkleGameFactory(gameBeacon);
        console.log("FarkleGameFactory deployed at:", address(factory));

        // 5) Deploy leaderboard impl + proxy (initialize with factory)
        FarkleLeaderboard leaderboard = new FarkleLeaderboard(address(factory));
        console.log("FarkleLeaderboard impl at:", address(leaderboard));

        vm.stopBroadcast();
    }

    /// @dev Deploys an UpgradeableBeacon instance using the embedded creation bytecode
    function deployBeacon(
        address initialOwner,
        address initialImplementation,
        string memory tag
    ) public returns (address) {
        require(initialOwner != address(0), "owner zero");
        require(initialImplementation != address(0), "impl zero");
        require(initialImplementation.code.length > 0, "impl no code");

        bytes memory constructorArgs = abi.encode(
            initialOwner,
            initialImplementation
        );
        bytes memory deploymentBytecode = abi.encodePacked(
            BEACON_BYTECODE,
            constructorArgs
        );

        bytes32 deploymentSalt = keccak256(
            abi.encodePacked(block.chainid, msg.sender, tag)
        );

        address beacon;
        assembly {
            beacon := create2(
                0,
                add(deploymentBytecode, 0x20),
                mload(deploymentBytecode),
                deploymentSalt
            )
        }
        require(beacon != address(0), "beacon deploy failed");
        return beacon;
    }
}
