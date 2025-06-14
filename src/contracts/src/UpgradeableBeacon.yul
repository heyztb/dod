// solc UpgradeableBeacon.yul --bin --optimize-yul --optimize-runs=1  --evm-version=cancun --strict-assembly | grep -o "[0-9a-fA-F]\{32,\}" | sed "s/00$//"
object "UpgradeableBeacon" {
    code {
        codecopy(
            returndatasize(),
            datasize("UpgradeableBeacon"),
            0x40
        )
        let initialOwner := mload(returndatasize())
        let initialImplementation := mload(0x20)
        // Ensure that the upper 96 bits of
        // `initialOwner` and `initialImplementation` are clean.
        returndatacopy(
            returndatasize(),
            returndatasize(),
            shr(160, or(initialOwner, initialImplementation))
        )
        if iszero(extcodesize(initialImplementation)) {
            mstore(returndatasize(), 0x6d3e283b) // `NewImplementationHasNoCode()`.
            revert(0x1c, 0x04)
        }
        // Store the `initialOwner`.
        sstore(0x4343a0dc92ed22dbfc, initialOwner)
        // Store the `initialImplementation`.
        sstore(0x911c5a209f08d5ec5e, initialImplementation)
        // Emit the {Upgraded} event.
        log2(
            codesize(),
            returndatasize(),
            0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b,
            initialImplementation
        )
        // Emit the {OwnershipTransferred} event.
        log3(
            codesize(),
            returndatasize(),
            0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0,
            returndatasize(),
            initialOwner
        )
        // Deploy the contract
        datacopy(returndatasize(), dataoffset("runtime"), datasize("runtime"))
        return(returndatasize(), datasize("runtime"))
    }
    object "runtime" {
        code {
            // `implementation()`.
            if eq(0x5c60da1b, shr(224, calldataload(returndatasize()))) {
                mstore(returndatasize(), sload(0x911c5a209f08d5ec5e))
                return(returndatasize(), 0x20)
            }
            let implementationSlot := 0x911c5a209f08d5ec5e
            let ownerSlot := 0x4343a0dc92ed22dbfc
            let sel := shr(224, calldataload(returndatasize()))
            // `owner()`.
            if eq(0x8da5cb5b, sel) {
                mstore(returndatasize(), sload(ownerSlot))
                return(returndatasize(), 0x20)
            }
            let mode :=
                or(
                    eq(0x715018a6, sel), // `renounceOwnership()`.
                    or(
                        shl(1, eq(0xf2fde38b, sel)), // `transferOwnership(address)`.
                        shl(2, eq(0x3659cfe6, sel)) // `upgradeTo(address)`.
                    )
                )
            // If the `mode` is zero, it means we don't have a function selector match. Revert.
            returndatacopy(returndatasize(), returndatasize(), iszero(mode))
            let oldOwner := sload(ownerSlot)
            // Require that the caller is the current owner.
            if iszero(eq(caller(), oldOwner)) {
                mstore(returndatasize(), 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
            let a := returndatasize()
            // `transferOwnership(address)`, `upgradeTo(address)`.
            if and(mode, 6) {
                a := calldataload(0x04)
                // Require that the calldata is at least (32 + 4) bytes
                // and the address does not have dirty upper bits.
                returndatacopy(
                    returndatasize(),
                    returndatasize(),
                    or(lt(calldatasize(), 0x24), shr(160, a))
                )
                // `upgradeTo(address)`.
                if eq(mode, 4) {
                    if iszero(extcodesize(a)) {
                        mstore(returndatasize(), 0x6d3e283b) // `NewImplementationHasNoCode()`.
                        revert(0x1c, 0x04)
                    }
                    // Store the new implementation.
                    sstore(implementationSlot, a)
                    // Emit the {Upgraded} event.
                    log2(
                        codesize(),
                        returndatasize(),
                        0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b,
                        a
                    )
                    stop()
                }
                // `transferOwnership(address)` and `a == address(0)`.
                if iszero(a) {
                    mstore(returndatasize(), 0x7448fbae) // `NewOwnerIsZeroAddress()`.
                    revert(0x1c, 0x04)
                }
            }
            // `renounceOwnership()`, `transferOwnership(address)`.
            // Store the new owner.
            sstore(ownerSlot, a)
            // Emit the {OwnershipTransferred} event.
            log3(
                codesize(),
                returndatasize(),
                0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0,
                oldOwner,
                a
            )
            stop()
        }
    }
}