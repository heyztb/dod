// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {FarkleGameImpl} from "src/impl/FarkleGameImpl.sol";
import {IFarkleGame} from "src/interface/IFarkleGame.sol";
import {SupportedTokens} from "src/library/Token.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {LibClone} from "solady/utils/LibClone.sol";

interface IBeacon {
    function implementation() external view returns (address);

    function transferOwnership(address newOwner) external;
}

/// @notice Tests currently focus on joining, leaving, paying the entry fee, and receiving a refund after leaving (but before the game ends).
contract FarkleGameImplTest is Test {
    FarkleGameImpl public implementation;
    address public beacon;
    FarkleGameImpl public game;

    address constant VRF_COORDINATOR =
        0xd5D517aBE5cF79B7e95eC98dB0f0277788aFF634; // Base mainnet
    address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; // Base mainnet
    address constant SAFE = 0x6052F75B3FbDd4A89d6a0E4Be7119Db18ea20a35;

    // Beacon bytecode from UpgradeableBeacon.yul
    bytes constant BEACON_BYTECODE =
        hex"60406101ce3d393d5160205180821760a01c3d3d3e803b1560875781684343a0dc92ed22dbfc558068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a23d7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3610139806100953d393df35b636d3e283b3d526004601cfdfe3d3560e01c635c60da1b14610127573d3560e01c80638da5cb5b146101155780633659cfe61460021b8163f2fde38b1460011b179063715018a6141780153d3d3e684343a0dc92ed22dbfc54803303610108573d9160068116610090575b5081684343a0dc92ed22dbfc557f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e03d38a3005b915060048035928360a01c60243610173d3d3e146100c15781156100b4575f61005d565b637448fbae3d526004601cfd5b50803b156100fb578068911c5a209f08d5ec5e557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b3d38a2005b636d3e283b3d526004601cfd5b6382b429003d526004601cfd5b684343a0dc92ed22dbfc543d5260203df35b68911c5a209f08d5ec5e543d5260203df3";

    address player1 = makeAddr("player1");
    address player2 = makeAddr("player2");
    address player3 = makeAddr("player3");
    address player4 = makeAddr("player4");
    address beaconOwner = makeAddr("beaconOwner");
    address safe = 0x6052F75B3FbDd4A89d6a0E4Be7119Db18ea20a35;

    uint256 constant ENTRY_FEE = 10e6; // 10 USDC

    function setUp() public {
        // Fork Base mainnet for real USDC testing
        vm.createSelectFork(vm.envString("BASE_RPC_URL"));

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

        // Deploy game proxy using LibClone with initialization
        game = FarkleGameImpl(
            payable(LibClone.deployERC1967BeaconProxy(beacon))
        );
        game.initialize(SupportedTokens.Token.USDC, ENTRY_FEE);

        // Give players USDC
        deal(USDC, player1, 1000e6);
        deal(USDC, player2, 1000e6);
        deal(USDC, player3, 1000e6);
        deal(USDC, player4, 1000e6);

        // Approve game contract
        vm.prank(player1);
        IERC20(USDC).approve(address(game), type(uint256).max);
        vm.prank(player2);
        IERC20(USDC).approve(address(game), type(uint256).max);
        vm.prank(player3);
        IERC20(USDC).approve(address(game), type(uint256).max);
        vm.prank(player4);
        IERC20(USDC).approve(address(game), type(uint256).max);
    }

    function createNewGame(
        SupportedTokens.Token token,
        uint256 entryFee
    ) internal returns (FarkleGameImpl) {
        game = FarkleGameImpl(
            payable(LibClone.deployERC1967BeaconProxy(beacon))
        );
        game.initialize(token, entryFee);
        return game;
    }

    // ============ Join Tests ============

    function test_JoinGame() public {
        vm.prank(player1);
        game.join();

        assertEq(game.host(), player1, "Host should be player1");
        assertEq(game.players(0), player1, "First player should be player1");
    }

    function test_JoinGame_MultipleUsers() public {
        vm.prank(player1);
        game.join();

        vm.prank(player2);
        game.join();

        assertEq(game.host(), player1);
        assertEq(game.players(0), player1);
        assertEq(game.players(1), player2);
    }

    function test_RevertWhen_AlreadyJoined() public {
        vm.prank(player1);
        game.join();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.AlreadyJoined.selector);
        game.join();
    }

    function test_RevertWhen_GameFull() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();
        vm.prank(player3);
        game.join();
        vm.prank(player4);
        game.join();

        address player5 = makeAddr("player5");
        vm.prank(player5);
        vm.expectRevert(FarkleGameImpl.GameFull.selector);
        game.join();
    }

    function test_RevertWhen_JoinAfterGameStart() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.startGame();

        vm.prank(player3);
        vm.expectRevert(FarkleGameImpl.GameAlreadyStarted.selector);
        game.join();
    }

    // ============ Entry Fee Tests ============

    function test_PayEntryFee() public {
        vm.prank(player1);
        game.join();

        uint256 balanceBefore = IERC20(USDC).balanceOf(player1);

        vm.prank(player1);
        game.payEntryFee();

        uint256 balanceAfter = IERC20(USDC).balanceOf(player1);
        assertEq(balanceBefore - balanceAfter, ENTRY_FEE);
        assertEq(game.pot(), ENTRY_FEE);
    }

    function test_RevertWhen_PayEntryFeeWithoutJoining() public {
        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.MustJoinGame.selector);
        game.payEntryFee();
    }

    function test_RevertWhen_PayEntryFeeTwice() public {
        vm.prank(player1);
        game.join();

        vm.prank(player1);
        game.payEntryFee();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.AlreadyPaidEntryFee.selector);
        game.payEntryFee();
    }

    function test_RevertWhen_PayEntryFeeAfterGameStart() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.startGame();

        vm.prank(player2);
        vm.expectRevert(FarkleGameImpl.GameAlreadyStarted.selector);
        game.payEntryFee();
    }

    // ============ Leave Tests ============

    function test_LeaveGame() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player2);
        game.leave();

        assertEq(game.players(0), player1);
        vm.expectRevert();
        game.players(1);
    }

    function test_LeaveGame_HostTransfer() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.leave();

        assertEq(game.host(), player2);
    }

    function test_LeaveGame_LastPlayer() public {
        vm.prank(player1);
        game.join();

        vm.prank(player1);
        game.leave();

        assertTrue(game.gameEnded());
    }

    function test_RevertWhen_LeaveWithoutJoining() public {
        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.MustJoinGame.selector);
        game.leave();
    }

    // ============ Refund Tests ============

    function test_WithdrawRefund() public {
        vm.prank(player1);
        game.join();
        vm.prank(player1);
        game.payEntryFee();

        uint256 balanceBefore = IERC20(USDC).balanceOf(player1);

        vm.prank(player1);
        game.withdrawRefund();

        uint256 balanceAfter = IERC20(USDC).balanceOf(player1);
        assertEq(balanceAfter - balanceBefore, ENTRY_FEE);
        assertEq(game.pot(), 0);
    }

    function test_RevertWhen_WithdrawRefundWithoutPaying() public {
        vm.prank(player1);
        game.join();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.InvalidRefundRequest.selector);
        game.withdrawRefund();
    }

    // ============ Start Game Tests ============

    function test_StartGame() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.startGame();

        assertFalse(game.startable());
    }

    function test_RevertWhen_StartGameNotEnoughPlayers() public {
        vm.prank(player1);
        game.join();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.NotEnoughPlayers.selector);
        game.startGame();
    }

    function test_RevertWhen_StartGameNotHost() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player2);
        vm.expectRevert(FarkleGameImpl.MustBeHost.selector);
        game.startGame();
    }

    function test_RevertWhen_StartGameTwice() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.startGame();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.GameAlreadyStarted.selector);
        game.startGame();
    }

    // ============ ETH Game Tests ============

    function test_ETHGame_Join() public {
        FarkleGameImpl ethGame = createNewGame(
            SupportedTokens.Token.ETH,
            0.01 ether
        );

        vm.prank(player1);
        ethGame.join();

        assertEq(ethGame.host(), player1);
    }

    function test_ETHGame_PayEntryFee() public {
        uint256 entryFee = 0.01 ether;
        FarkleGameImpl ethGame = createNewGame(
            SupportedTokens.Token.ETH,
            entryFee
        );

        vm.deal(player1, 1 ether);

        vm.prank(player1);
        ethGame.join();

        vm.prank(player1);
        ethGame.payEntryFee{value: entryFee}();

        assertEq(address(ethGame).balance, entryFee);
        assertEq(ethGame.pot(), entryFee);
    }

    function test_RevertWhen_ETHGame_NotEnoughEther() public {
        uint256 entryFee = 0.01 ether;
        FarkleGameImpl ethGame = createNewGame(
            SupportedTokens.Token.ETH,
            entryFee
        );

        vm.deal(player1, 1 ether);

        vm.prank(player1);
        ethGame.join();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.NotEnoughEther.selector);
        ethGame.payEntryFee{value: 0.005 ether}();
    }

    // ============ Free Game Tests ============

    function test_FreeGame_NoEntryFee() public {
        FarkleGameImpl freeGame = createNewGame(SupportedTokens.Token.USDC, 0);

        vm.prank(player1);
        freeGame.join();
        vm.prank(player2);
        freeGame.join();

        vm.prank(player1);
        freeGame.startGame();

        assertEq(freeGame.pot(), 0);
    }

    function test_RevertWhen_PayEntryFeeOnFreeGame() public {
        FarkleGameImpl freeGame = createNewGame(SupportedTokens.Token.USDC, 0);

        vm.prank(player1);
        freeGame.join();

        vm.prank(player1);
        vm.expectRevert(FarkleGameImpl.NoEntryFee.selector);
        freeGame.payEntryFee();
    }

    // ============ Pause Tests ============

    function test_Pause() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.startGame();

        vm.prank(SAFE);
        game.acceptOwnership();
        vm.prank(SAFE);
        game.pause();

        assertTrue(game.paused());
    }

    function test_RevertWhen_PauseBeforeStart() public {
        vm.prank(SAFE);
        game.acceptOwnership();
        vm.expectRevert(FarkleGameImpl.GameNotStarted.selector);
        vm.prank(SAFE);
        game.pause();
    }

    function test_RevertWhen_PauseNotOwner() public {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.startGame();

        vm.prank(player1);
        vm.expectRevert();
        game.pause();
    }

    // ============ View Function Tests ============

    function test_GetCurrentDiceValues() public view {
        uint8[6] memory values = game.getCurrentDiceValues();
        // Initial dice should be [1,1,1,1,1,1] (unpacked from 0)
        for (uint256 i = 0; i < 6; i++) {
            assertEq(values[i], 1);
        }
    }

    function test_GetSelectedMask() public view {
        assertEq(game.getSelectedMask(), 0);
    }

    function test_GetTurnScore() public view {
        assertEq(game.getTurnScore(), 0);
    }

    function test_GetAvailableCount() public view {
        assertEq(game.getAvailableCount(), 6);
    }

    // ============ Integration Test Helpers ============

    function setupTwoPlayerGame() internal {
        vm.prank(player1);
        game.join();
        vm.prank(player2);
        game.join();

        vm.prank(player1);
        game.payEntryFee();
        vm.prank(player2);
        game.payEntryFee();

        vm.prank(player1);
        game.startGame();
    }
}
