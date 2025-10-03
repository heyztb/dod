// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {FarkleGameFactory} from "src/factory/FarkleGameFactory.sol";
import {FarkleGameImpl} from "src/impl/FarkleGameImpl.sol";
import {IFarkleGame} from "src/interface/IFarkleGame.sol";
import {SupportedTokens} from "src/library/Token.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

interface IBeacon {
    function implementation() external view returns (address);

    function owner() external view returns (address);
}

contract FarkleGameFactoryTest is Test {
    FarkleGameFactory public factory;
    FarkleGameImpl public implementation;
    address public beacon;

    address constant VRF_COORDINATOR =
        0xd5D517aBE5cF79B7e95eC98dB0f0277788aFF634; // Base mainnet
    address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; // Base mainnet
    address constant SAFE = 0x6052F75B3FbDd4A89d6a0E4Be7119Db18ea20a35;

    // Beacon bytecode from UpgradeableBeacon.yul
    bytes constant BEACON_BYTECODE =
        hex"60406101ce3d393d5160205180821760a01c3d3d3e803b1560875781684343a0dc92ed22dbfc558068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a23d7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3610139806100953d393df35b636d3e283b3d526004601cfdfe3d3560e01c635c60da1b14610127573d3560e01c80638da5cb5b146101155780633659cfe61460021b8163f2fde38b1460011b179063715018a6141780153d3d3e684343a0dc92ed22dbfc54803303610108573d9160068116610090575b5081684343a0dc92ed22dbfc557f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3005b915060048035928360a01c60243610173d3d3e146100c15781156100b4575f61005d565b637448fbae3d526004601cfd5b50803b156100fb578068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a2005b636d3e283b3d526004601cfd5b6382b429003d526004601cfd5b684343a0dc92ed22dbfc543d5260203df35b68911c5a209f08d5ec5e543d5260203df3";

    address beaconOwner = makeAddr("beaconOwner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    uint256 constant ENTRY_FEE = 10e6; // 10 USDC

    function setUp() public {
        // Fork Base mainnet for real USDC testing
        vm.createSelectFork("base");

        // Deploy implementation
        implementation = new FarkleGameImpl(VRF_COORDINATOR);

        // Deploy beacon with owner and implementation
        bytes memory creationCode = abi.encodePacked(
            BEACON_BYTECODE,
            abi.encode(beaconOwner, address(implementation))
        );

        assembly {
            sstore(
                beacon.slot,
                create(0, add(creationCode, 0x20), mload(creationCode))
            )
        }
        require(beacon != address(0), "Beacon deployment failed");

        // Deploy factory
        factory = new FarkleGameFactory(beacon);
        console2.log("Factory deployed at:", address(factory));
        console2.log("Factory owner (SAFE):", factory.owner());
    }

    // ============ Factory Deployment Tests ============

    function test_FactoryDeployment() public view {
        assertEq(factory.gameBeacon(), beacon);
        assertEq(factory.owner(), SAFE);
    }

    function test_BeaconConfiguration() public view {
        assertEq(IBeacon(beacon).implementation(), address(implementation));
        assertEq(IBeacon(beacon).owner(), beaconOwner);
    }

    // ============ Game Creation Tests ============

    function test_CreateGame() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );

        assertTrue(game != address(0), "Game address should not be zero");
        assertTrue(
            factory.isGame(game),
            "Game should be registered in factory"
        );
    }

    function test_CreateGame_InitializationValues() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );

        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));

        // Check initialization values
        assertEq(
            uint(gameImpl.token()),
            uint(SupportedTokens.Token.USDC),
            "Token should be USDC"
        );
        assertEq(gameImpl.entryFee(), ENTRY_FEE, "Entry fee should match");
        assertTrue(gameImpl.startable(), "Game should be startable");
        assertEq(
            gameImpl.getAvailableCount(),
            6,
            "Should have 6 available dice"
        );
    }

    function test_CreateGame_OwnershipTransfer() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );

        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));
        console2.log(
            "Game owner before SAFE accepts ownership",
            gameImpl.owner()
        );
        vm.prank(SAFE);
        gameImpl.acceptOwnership();

        console2.log(
            "Game owner after SAFE accepts ownership:",
            gameImpl.owner()
        );
        console2.log("Expected owner (SAFE):", SAFE);

        // This is the critical test - verify ownership was properly transferred to SAFE
        assertEq(
            gameImpl.owner(),
            SAFE,
            "Game owner should be SAFE after initialization"
        );
    }

    function test_CreateGame_MultipleGames() public {
        address game1 = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );
        address game2 = factory.createGame(
            SupportedTokens.Token.ETH,
            0.01 ether
        );
        address game3 = factory.createGame(SupportedTokens.Token.USDC, 0);

        assertTrue(factory.isGame(game1), "Game 1 should be registered");
        assertTrue(factory.isGame(game2), "Game 2 should be registered");
        assertTrue(factory.isGame(game3), "Game 3 should be registered");

        assertTrue(
            game1 != game2 && game2 != game3 && game1 != game3,
            "All games should have unique addresses"
        );
    }

    function test_CreateGame_ETHGame() public {
        uint256 ethEntryFee = 0.01 ether;
        address game = factory.createGame(
            SupportedTokens.Token.ETH,
            ethEntryFee
        );

        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));

        assertEq(
            uint(gameImpl.token()),
            uint(SupportedTokens.Token.ETH),
            "Token should be ETH"
        );
        assertEq(gameImpl.entryFee(), ethEntryFee, "Entry fee should match");
    }

    function test_CreateGame_FreeGame() public {
        address game = factory.createGame(SupportedTokens.Token.USDC, 0);
        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));
        assertEq(gameImpl.entryFee(), 0, "Entry fee should be zero");
    }

    function test_CreateGame_EmitsEvent() public {
        vm.expectEmit(false, false, false, false);
        emit FarkleGameFactory.GameCreated(address(0)); // We don't know the address yet

        factory.createGame(SupportedTokens.Token.USDC, ENTRY_FEE);
    }

    // ============ Game Functionality After Creation Tests ============

    function test_CreatedGame_CanJoin() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );

        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));

        vm.prank(user1);
        gameImpl.join();

        assertEq(gameImpl.host(), user1, "User1 should be the host");
        assertEq(
            gameImpl.players(0),
            user1,
            "User1 should be in players array"
        );
    }

    function test_CreatedGame_SafeCanPauseAfterAcceptingOwnership() public {
        address game = factory.createGame(SupportedTokens.Token.USDC, 0);

        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));

        // Join and start game
        vm.prank(user1);
        gameImpl.join();
        vm.prank(user2);
        gameImpl.join();
        vm.prank(user1);
        gameImpl.startGame();

        vm.prank(SAFE);
        gameImpl.acceptOwnership();
        vm.prank(SAFE);
        gameImpl.pause();

        assertTrue(gameImpl.paused(), "Game should be paused");
    }

    // ============ Pause/Unpause Tests ============

    function test_PauseFactory() public {
        vm.prank(SAFE);
        factory.pause();

        assertTrue(factory.paused(), "Factory should be paused");
    }

    function test_UnpauseFactory() public {
        vm.prank(SAFE);
        factory.pause();

        vm.prank(SAFE);
        factory.unpause();

        assertFalse(factory.paused(), "Factory should be unpaused");
    }

    function test_RevertWhen_CreateGameWhilePaused() public {
        vm.prank(SAFE);
        factory.pause();

        vm.expectRevert();
        factory.createGame(SupportedTokens.Token.USDC, ENTRY_FEE);
    }

    function test_RevertWhen_PauseNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        factory.pause();
    }

    function test_RevertWhen_UnpauseNotOwner() public {
        vm.prank(SAFE);
        factory.pause();

        vm.prank(user1);
        vm.expectRevert();
        factory.unpause();
    }

    // ============ isGame Tests ============

    function test_IsGame_ReturnsTrueForCreatedGames() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );
        assertTrue(factory.isGame(game), "Should return true for created game");
    }

    function test_IsGame_ReturnsFalseForRandomAddress() public {
        address randomAddress = makeAddr("random");
        assertFalse(
            factory.isGame(randomAddress),
            "Should return false for random address"
        );
    }

    function test_IsGame_ReturnsFalseForFactory() public view {
        assertFalse(
            factory.isGame(address(factory)),
            "Should return false for factory itself"
        );
    }

    // ============ Integration Tests ============

    function test_Integration_CreateAndPlayGame() public {
        // Create game
        address game = factory.createGame(SupportedTokens.Token.USDC, 0);
        FarkleGameImpl gameImpl = FarkleGameImpl(payable(game));

        // Join game
        vm.prank(user1);
        gameImpl.join();
        vm.prank(user2);
        gameImpl.join();

        // Start game
        vm.prank(user1);
        gameImpl.startGame();

        // Verify game started
        assertFalse(
            gameImpl.startable(),
            "Game should not be startable after start"
        );
        assertEq(gameImpl.currentPlayer(), 0, "Current player should be 0");
    }

    function test_Integration_MultipleGamesIndependent() public {
        // Create two games
        address game1 = factory.createGame(SupportedTokens.Token.USDC, 0);
        address game2 = factory.createGame(SupportedTokens.Token.USDC, 0);

        FarkleGameImpl gameImpl1 = FarkleGameImpl(payable(game1));
        FarkleGameImpl gameImpl2 = FarkleGameImpl(payable(game2));

        // User1 joins game1
        vm.prank(user1);
        gameImpl1.join();

        // User2 joins game2
        vm.prank(user2);
        gameImpl2.join();

        // Verify they are independent
        assertEq(gameImpl1.host(), user1, "Game1 host should be user1");
        assertEq(gameImpl2.host(), user2, "Game2 host should be user2");

        vm.expectRevert();
        gameImpl1.players(1); // Game1 should only have 1 player

        vm.expectRevert();
        gameImpl2.players(1); // Game2 should only have 1 player
    }

    // ============ Ownership Assumption Validation Tests ============

    function test_OwnershipAssumption_InitializerSlotSetCorrectly() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );

        // Read storage slot 0 (where we set the initializer in assembly)
        bytes32 slot0 = vm.load(game, bytes32(uint256(0)));
        address storedInitializer = address(uint160(uint256(slot0)));

        console2.log("Stored initializer:", storedInitializer);
        console2.log("Factory address:", address(factory));
        console2.log("Current owner:", FarkleGameImpl(payable(game)).owner());

        // The initializer should have been the factory
        assertEq(
            storedInitializer,
            address(factory),
            "Slot 0 should contain factory address"
        );
    }

    function test_OwnershipAssumption_PendingOwnerSetCorrectly() public {
        address game = factory.createGame(
            SupportedTokens.Token.USDC,
            ENTRY_FEE
        );

        // Read storage slot 1 (where we set the pending owner in assembly)
        bytes32 slot1 = vm.load(game, bytes32(uint256(1)));
        address storedPendingOwner = address(uint160(uint256(slot1)));

        console2.log("Stored pending owner:", storedPendingOwner);
        console2.log("Factory address:", address(factory));
        console2.log("Current owner:", FarkleGameImpl(payable(game)).owner());

        // The pending owner should have been the SAFE
        assertEq(
            storedPendingOwner,
            SAFE,
            "Slot 1 should contain SAFE address"
        );
    }
}
