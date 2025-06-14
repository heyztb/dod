// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from '@solady/auth/Ownable.sol';
import {LibClone} from '@solady/utils/LibClone.sol';

contract FarkleGameFactory is Ownable {
	constructor() Ownable() {
		_initializeOwner(msg.sender);
	}
}
