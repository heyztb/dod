// SPDX-License-Identifier: AGPL-3.0-only

/// @title FarkleTreasuryImpl
/// @author heyztb.eth
/// @notice This contract holds the fees collected from wagers in Dice of Destiny.
pragma solidity ^0.8.30;

import {IFarkleTreasury} from '@interface/IFarkleTreasury.sol';
import {Ownable} from '@solady/auth/Ownable.sol';

contract FarkleTreasuryImpl is IFarkleTreasury, Ownable {
	event EthReceived(address indexed sender, uint256 amount);
	event EthWithdrawn(address indexed receiver, uint256 amount);

	constructor() {
		_initializeOwner(msg.sender);
	}

	receive() external payable {
		emit EthReceived(msg.sender, msg.value);
	}

	function withdraw(uint256 amount) public override onlyOwner {
		(bool success, ) = payable(msg.sender).call{value: amount}('');
		require(success, 'Transfer failed');
		emit EthWithdrawn(msg.sender, amount);
	}

	function withdrawAll() public override onlyOwner {
		withdraw(address(this).balance);
	}
}
