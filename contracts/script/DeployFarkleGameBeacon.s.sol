// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {FarkleGameImpl} from "src/impl/FarkleGameImpl.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployFarkleGameBeacon is Script {
    // Events matching the beacon contract
    event Upgraded(address indexed implementation);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function run(address vrfCoordinator, address treasury) external {
        vm.startBroadcast();
        address deployer = msg.sender;

        console.log("Deploying with account:", deployer);

        // First deploy the implementation contract
        FarkleGameImpl implementation = new FarkleGameImpl(
            vrfCoordinator,
            treasury
        );
        console.log("FarkleGameImpl deployed at:", address(implementation));

        // Deploy the beacon with the implementation
        address beacon = deployBeacon(deployer, address(implementation));
        console.log("UpgradeableBeacon deployed at:", beacon);

        vm.stopBroadcast();
    }

    function deployBeacon(
        address initialOwner,
        address initialImplementation
    ) public returns (address) {
        require(
            initialOwner != address(0),
            "Initial owner cannot be zero address"
        );
        require(
            initialImplementation != address(0),
            "Initial implementation cannot be zero address"
        );
        require(
            initialImplementation.code.length > 0,
            "Implementation must have code"
        );

        // Get the compiled bytecode for the UpgradeableBeacon
        bytes memory bytecode = getBeaconBytecode();

        // Encode constructor parameters (initialOwner, initialImplementation)
        bytes memory constructorArgs = abi.encode(
            initialOwner,
            initialImplementation
        );

        // Combine bytecode with constructor arguments
        bytes memory deploymentBytecode = abi.encodePacked(
            bytecode,
            constructorArgs
        );

        bytes32 deploymentSalt = salt();
        address beacon;
        assembly {
            beacon := create2(
                0, // value
                add(deploymentBytecode, 0x20), // bytecode start
                mload(deploymentBytecode), // bytecode length
                deploymentSalt // salt for deterministic deployment
            )
        }

        require(beacon != address(0), "Beacon deployment failed");
        return beacon;
    }

    function getBeaconBytecode() internal pure returns (bytes memory) {
        // This is the optimized creation code from the Yul contract UpgradeableBeacon.yul
        // Compiled with: solc src/UpgradeableBeacon.yul --bin --optimize-yul --optimize-runs=1  --evm-version=cancun --strict-assembly | grep -o "[0-9a-fA-F]\{32,\}" | sed "s/00$//"

        return
            hex"60406101ce3d393d5160205180821760a01c3d3d3e803b1560875781684343a0dc92ed22dbfc558068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a23d7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3610139806100953d393df35b636d3e283b3d526004601cfdfe3d3560e01c635c60da1b14610127573d3560e01c80638da5cb5b146101155780633659cfe61460021b8163f2fde38b1460011b179063715018a6141780153d3d3e684343a0dc92ed22dbfc54803303610108573d9160068116610090575b5081684343a0dc92ed22dbfc557f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3005b915060048035928360a01c60243610173d3d3e146100c15781156100b4575f61005d565b637448fbae3d526004601cfd5b50803b156100fb578068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a2005b636d3e283b3d526004601cfd5b6382b429003d526004601cfd5b684343a0dc92ed22dbfc543d5260203df35b68911c5a209f08d5ec5e543d5260203df3";
    }

    function salt() internal view returns (bytes32) {
        // Generate a deterministic salt based on the current chain and deployer
        return
            keccak256(
                abi.encodePacked(block.chainid, msg.sender, "FarkleGameBeacon")
            );
    }
}
