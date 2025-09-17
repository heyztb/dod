// SPDX-License-Identifier: AGPL-3.0-only
/// @title IFarkleTreasury.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

interface IFarkleTreasury {
	function initialize() external;

	function withdraw(uint256 amount) external;

	function withdrawAll() external;

	function withdrawERC20(address token, uint256 amount) external;

	function withdrawAllERC20(address token) external;
}
