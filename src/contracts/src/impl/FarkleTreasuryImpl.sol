// SPDX-License-Identifier: AGPL-3.0-only

/// @title FarkleTreasuryImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleTreasury} from '@interface/IFarkleTreasury.sol';
import {Ownable} from '@solady/auth/Ownable.sol';
import {Initializable} from '@solady/utils/Initializable.sol';
import {UUPSUpgradeable} from '@solady/utils/UUPSUpgradeable.sol';
import {IERC20} from '@openzeppelin/token/ERC20/IERC20.sol';

contract FarkleTreasuryImpl is IFarkleTreasury, Initializable, Ownable, UUPSUpgradeable {
	event EthReceived(address indexed sender, uint256 amount);
	event EthWithdrawn(address indexed receiver, uint256 amount);
	event ERC20Withdrawn(address indexed receiver, address indexed token, uint256 amount);

	constructor() {
		_disableInitializers();
	}

	function initialize() public initializer {
		_initializeOwner(msg.sender);
	}

	function _authorizeUpgrade(address) internal override onlyOwner {}

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

	function withdrawERC20(address token, uint256 amount) public override onlyOwner {
		bool success = IERC20(token).transfer(msg.sender, amount);
		require(success, 'Transfer failed');
		emit ERC20Withdrawn(msg.sender, token, amount);
	}

	function withdrawAllERC20(address token) public override onlyOwner {
		withdrawERC20(token, IERC20(token).balanceOf(address(this)));
	}
}
