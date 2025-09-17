// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FarkleGameFactory} from "src/factory/FarkleGameFactory.sol";
import {FarkleRoomFactory} from "src/factory/FarkleRoomFactory.sol";
import {FarkleLeaderboard} from "src/impl/FarkleLeaderboardImpl.sol";
import {LibClone} from "solady/utils/LibClone.sol";

contract DeploySystem is Script {
    function run(
        address gameBeaconAddress,
        address roomBeaconAddress
    ) external {
        require(
            gameBeaconAddress != address(0),
            "Game beacon address cannot be zero"
        );
        require(
            roomBeaconAddress != address(0),
            "Room beacon address cannot be zero"
        );

        vm.startBroadcast();

        // 1. Deploy the FarkleGameFactory using the provided game beacon address
        FarkleGameFactory gameFactory = new FarkleGameFactory(
            gameBeaconAddress
        );
        console.log("Deploying FarkleGameFactory at:", address(gameFactory));

        // 2. Deploy the FarkleRoomFactory using the room beacon and game factory addresses
        FarkleRoomFactory roomFactory = new FarkleRoomFactory(
            roomBeaconAddress,
            address(gameFactory)
        );
        console.log("Deploying FarkleRoomFactory at:", address(roomFactory));

        // 3. Deploy the Leaderboard Proxy (which needs the game factory address)
        FarkleLeaderboard leaderboardImpl = new FarkleLeaderboard();
        console.log(
            "Deploying FarkleLeaderboard impl at:",
            address(leaderboardImpl)
        );
        address leaderboardProxy = LibClone.deployERC1967(
            address(leaderboardImpl),
            abi.encodeCall(FarkleLeaderboard.initialize, (address(gameFactory)))
        );
        console.log(
            "Deploying FarkleLeaderboardProxy at:",
            address(leaderboardProxy)
        );

        // 4. Link the Game Factory to the Leaderboard
        gameFactory.setLeaderboard(leaderboardProxy);
        console.log("FarkleGameFactory leaderboard set to:", leaderboardProxy);

        vm.stopBroadcast();
    }
}
