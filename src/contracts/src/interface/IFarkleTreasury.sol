// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

interface IFarkleTreasury {
	function withdraw(uint256 amount) external;

	function withdrawAll() external;
}
