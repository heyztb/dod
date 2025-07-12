// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Script} from 'forge-std/Script.sol';
import {FarkleLeaderboard} from '../src/impl/FarkleLeaderboardImpl.sol';
import {LibClone} from '@solady/utils/LibClone.sol';
import {console} from 'forge-std/console.sol';

contract DeployFarkleLeaderboardProxy is Script {
	function run() external {
		vm.startBroadcast();
		address leaderboard = address(new FarkleLeaderboard());
		console.log('Deploying FarkleLeaderboard at:', address(leaderboard));
		address proxy = LibClone.deployERC1967(
			leaderboard,
			abi.encodeCall(FarkleLeaderboard.initialize, ())
		);
		console.log('Deploying FarkleLeaderboardProxy at:', address(proxy));
		vm.stopBroadcast();
	}
}
