// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {IFarkleTreasury} from "../src/interface/IFarkleTreasury.sol";
import {FarkleTreasuryImpl} from "../src/impl/FarkleTreasuryImpl.sol";
import {LibClone} from "solady/utils/LibClone.sol";
import {console} from "forge-std/console.sol";

contract DeployTreasury is Script {
    function run() external {
        vm.startBroadcast();
        FarkleTreasuryImpl treasuryImpl = new FarkleTreasuryImpl();
        console.log("Deployed Treasury Impl at:", address(treasuryImpl));
        address treasury = LibClone.deployERC1967(
            address(treasuryImpl),
            abi.encodeCall(IFarkleTreasury.initialize, ())
        );
        console.log("FarkleTreasury deployed at:", address(treasury));
        vm.stopBroadcast();
    }
}
