// SPDX-License-Identifier: AGPL-3.0-only

/// @title FarkleTreasuryImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {IFarkleTreasury} from "src/interface/IFarkleTreasury.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {Initializable} from "solady/utils/Initializable.sol";
import {UUPSUpgradeable} from "solady/utils/UUPSUpgradeable.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract FarkleTreasuryImpl is
    IFarkleTreasury,
    Initializable,
    Ownable,
    UUPSUpgradeable
{
    event EthReceived(address indexed sender, uint256 amount);
    event EthWithdrawn(address indexed receiver, uint256 amount);
    event ERC20Withdrawn(
        address indexed receiver,
        address indexed token,
        uint256 amount
    );

    error ETHTransferError(address to, uint256 amount);
    error ERC20TransferError(address token, address to, uint256 amount);

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
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert ETHTransferError(msg.sender, amount);
        emit EthWithdrawn(msg.sender, amount);
    }

    function withdrawAll() public override onlyOwner {
        withdraw(address(this).balance);
    }

    function withdrawERC20(
        address token,
        uint256 amount
    ) public override onlyOwner {
        try IERC20(token).transfer(msg.sender, amount) returns (bool success) {
            if (!success) revert ERC20TransferError(token, msg.sender, amount);
        } catch {
            revert ERC20TransferError(token, msg.sender, amount);
        }
        emit ERC20Withdrawn(msg.sender, token, amount);
    }

    function withdrawAllERC20(address token) public override onlyOwner {
        try IERC20(token).balanceOf(address(this)) returns (uint256 amount) {
            withdrawERC20(token, amount);
        } catch {
            revert ERC20TransferError(token, msg.sender, 0);
        }
    }
}
