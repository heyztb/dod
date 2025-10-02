// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleGameImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {Initializable} from "solady/utils/Initializable.sol";
import {IFarkleGame} from "src/interface/IFarkleGame.sol";
import {IFarkleLeaderboard, PlayerResult} from "src/interface/IFarkleLeaderboard.sol";
import {SupportedTokens} from "src/library/Token.sol";
import {VRFConsumerBaseV2Plus} from "chainlink/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "chainlink/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Pausable} from "openzeppelin/utils/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin/utils/ReentrancyGuard.sol";

using SupportedTokens for SupportedTokens.Token;

contract FarkleGameImpl is
    IFarkleGame,
    Initializable,
    VRFConsumerBaseV2Plus,
    Pausable,
    ReentrancyGuard
{
    string public constant VERSION = "v1";
    uint256 public constant MAX_SCORE = 1_000;
    IFarkleLeaderboard public constant LEADERBOARD =
        IFarkleLeaderboard(address(0));
    address public constant TREASURY =
        0x3cF189902B4902745CE27dDc864E4a2fe7641a0c;
    address public constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address public constant SAFE = 0x6052F75B3FbDd4A89d6a0E4Be7119Db18ea20a35;
    SupportedTokens.Token public token;
    uint256 public entryFee;
    uint256 public pot;

    address public host;
    address[] public players;
    mapping(address => bool) isPlayer;
    uint256 public currentPlayer;
    address public finalTurnPlayer;
    address public winner;

    bool public startable = true;
    bool public finalTurn = false;
    bool public gameEnded = false;

    mapping(address => uint256) playerScores;
    mapping(address => uint256) farkleCounts;
    mapping(address => uint256) hotDiceCounts;
    mapping(address => bool) refundElligble;

    uint256 constant FEE_BASIS_POINTS = 250;
    uint256 constant FEE_DENOMINATOR = 10000;

    uint256 s_subscriptionId =
        110332509415864652465086222220959657000163978298414210005002692430465200668803;
    bytes32 s_keyHash =
        0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71;
    uint32 s_callbackGasLimit = 150000;
    uint16 s_requestConfirmations = 1;
    mapping(uint256 => address) s_requestToPlayer;
    mapping(address => bool) s_rollInProgress;

    struct DiceState {
        uint48 values;
        uint8 selectedMask;
        uint8 availableCount;
        uint32 turnScore;
        bool hasRolled;
    }

    DiceState public dice;

    event PlayerJoined(address indexed player);
    event PlayerLeft(address indexed player);
    event GameStarted();
    event GameClosed();
    event DiceThrown(address indexed player);
    event DiceRolled(
        uint256 indexed requestId,
        address indexed player,
        uint48 values
    );
    event DiceSelected(address indexed player, uint256 score);
    event Banked(address indexed player, uint256 turnScore, uint256 totalScore);
    event Farkled(address indexed player);
    event FinalTurn();
    event PlayerWon(
        address indexed player,
        SupportedTokens.Token token,
        uint256 amount
    );
    event GameOver(address indexed winner, uint256 score);

    error MustJoinGame();
    error AlreadyJoined();
    error GameFull();
    error MustBeHost();
    error NotEnoughPlayers();
    error GameNotStarted();
    error GameAlreadyStarted();
    error InvalidToken();
    error InvalidTreasury();
    error NotCurrentPlayer();
    error GameAlreadyOver();
    error GameMustBeOver();
    error MustBeWinner();
    error MustRollFirst();
    error MustRollAtLeastOnce();
    error RollInProgress();
    error DiceAlreadySelected();
    error NoScoringDice();
    error NoDiceAvailable();
    error InvalidSelection();
    error MustSelectAtLeastOneDie();
    error SelectionMustScorePoints();
    error NoEntryFee();
    error AlreadyPaidEntryFee();
    error NotEnoughEther();
    error WantUSDCNotETH();
    error USDCTransferFromError(address player);
    error USDCTransferError(address player);
    error FeeTransferError();
    error RefundTransferError();
    error WinnerTransferError();
    error InvalidWithdrawalRequest();
    error InvalidRefundRequest();
    error InvalidVoteRequest();
    error VRFRequestNotFound();

    modifier onlyCurrentPlayer() {
        if (msg.sender != players[currentPlayer]) revert NotCurrentPlayer();
        _;
    }

    modifier notAfterJoin() {
        if (isPlayer[msg.sender]) revert AlreadyJoined();
        _;
    }

    modifier onlyAfterJoin() {
        if (!isPlayer[msg.sender]) revert MustJoinGame();
        _;
    }

    modifier notBeforeGameStart() {
        if (startable) revert GameNotStarted();
        _;
    }

    modifier notAfterGameStart() {
        if (!startable) revert GameAlreadyStarted();
        _;
    }

    modifier notAfterGameOver() {
        if (gameEnded) revert GameAlreadyOver();
        _;
    }

    modifier onlyAfterGameOver() {
        if (!gameEnded) revert GameMustBeOver();
        _;
    }

    modifier onlyHost() {
        if (msg.sender != host) revert MustBeHost();
        _;
    }

    modifier onlyWinner() {
        if (msg.sender != winner) revert MustBeWinner();
        _;
    }

    modifier mustBeElligbleForRefund() {
        if (!refundElligble[msg.sender]) revert InvalidRefundRequest();
        _;
    }

    modifier gameMustHaveEntryFee() {
        if (entryFee == 0) revert NoEntryFee();
        _;
    }

    constructor(
        address _vrfCoordinator
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        if (_vrfCoordinator == address(0)) revert ZeroAddress();
        _disableInitializers();
    }

    function initialize(
        SupportedTokens.Token _token,
        uint256 _entryFee
    ) external initializer {
        token = _token;
        entryFee = _entryFee;
        dice = DiceState({
            values: 0,
            selectedMask: 0,
            availableCount: 6,
            turnScore: 0,
            hasRolled: false
        });
        transferOwnership(SAFE);
    }

    function pause() external onlyOwner notBeforeGameStart {
        _pause();
    }

    function unpause() external onlyOwner notBeforeGameStart {
        _unpause();
    }

    function join() external notAfterJoin notAfterGameStart {
        if (players.length == 4) {
            revert GameFull();
        }

        isPlayer[msg.sender] = true;
        players.push(msg.sender);
        if (players.length == 1) {
            host = msg.sender;
        }
        emit PlayerJoined(msg.sender);
    }

    function payEntryFee()
        external
        payable
        nonReentrant
        gameMustHaveEntryFee
        onlyAfterJoin
        notAfterGameStart
    {
        if (refundElligble[msg.sender]) revert AlreadyPaidEntryFee();
        pot += entryFee;
        refundElligble[msg.sender] = true;
        if (token.isETH()) {
            if (msg.value < entryFee) revert NotEnoughEther();
        } else if (token.isUSDC()) {
            IERC20(USDC).transferFrom(msg.sender, address(this), entryFee);
        }
    }

    function leave() external onlyAfterJoin notAfterGameStart {
        delete isPlayer[msg.sender];
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                if (host == msg.sender) {
                    host = (
                        players.length > 1
                            ? players[players.length - 1]
                            : address(0)
                    );
                }
                if (i < players.length - 1) {
                    players[i] = players[players.length - 1];
                }
                players.pop();
                emit PlayerLeft(msg.sender);
                if (players.length == 0) {
                    startable = false;
                    gameEnded = true;
                    emit GameClosed();
                }
                break;
            }
        }
    }

    function withdrawRefund()
        external
        nonReentrant
        gameMustHaveEntryFee
        mustBeElligbleForRefund
    {
        delete refundElligble[msg.sender];
        pot -= entryFee;
        if (token.isETH()) {
            (bool refund, ) = payable(msg.sender).call{value: entryFee}("");
            if (!refund) revert RefundTransferError();
        } else if (token.isUSDC()) {
            IERC20(USDC).transfer(msg.sender, entryFee);
        }
    }

    function withdrawWinnings()
        external
        nonReentrant
        gameMustHaveEntryFee
        onlyAfterGameOver
        onlyWinner
    {
        uint256 fee = (pot * FEE_BASIS_POINTS) / FEE_DENOMINATOR;
        uint256 winnings = pot - fee;

        if (token.isETH()) {
            (bool sent, ) = payable(msg.sender).call{value: winnings}("");
            if (!sent) {
                revert WinnerTransferError();
            }
        } else if (token.isUSDC()) {
            IERC20(USDC).transfer(msg.sender, winnings);
        }
    }

    function startGame() external nonReentrant onlyHost notAfterGameStart {
        if (players.length < 2) revert NotEnoughPlayers();
        startable = false;
        emit GameStarted();
    }

    function roll()
        external
        override
        onlyCurrentPlayer
        notBeforeGameStart
        notAfterGameOver
    {
        if (dice.availableCount == 0) revert NoDiceAvailable();

        if (s_rollInProgress[msg.sender]) revert RollInProgress();
        s_rollInProgress[msg.sender] = true;

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: s_requestConfirmations,
                callbackGasLimit: s_callbackGasLimit,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requestToPlayer[requestId] = msg.sender;
        emit DiceThrown(msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal virtual override {
        address player = s_requestToPlayer[requestId];
        if (player == address(0)) revert VRFRequestNotFound();
        delete s_rollInProgress[player];
        delete s_requestToPlayer[requestId];
        uint256 randomValue = randomWords[0];
        uint8[6] memory newValues = _unpackDiceValues(dice.values);

        for (uint256 i = 0; i < 6; i++) {
            if ((dice.selectedMask & (1 << i)) == 0) {
                newValues[i] = uint8((randomValue >> (i * 8)) % 6) + 1;
            }
        }

        dice.values = _packDiceValues(newValues);
        dice.hasRolled = true;

        emit DiceRolled(requestId, player, dice.values);

        if (!_hasAnyScore(newValues)) {
            _farkle(player);
        }
    }

    function selectDice(
        uint8[] calldata selectedIndices
    )
        external
        onlyCurrentPlayer
        notBeforeGameStart
        notAfterGameOver
        returns (uint256)
    {
        if (!dice.hasRolled) revert MustRollFirst();
        if (selectedIndices.length == 0) revert MustSelectAtLeastOneDie();

        // Validate selections
        uint8[6] memory currentValues = _unpackDiceValues(dice.values);
        for (uint256 i = 0; i < selectedIndices.length; i++) {
            uint8 index = selectedIndices[i];
            if (index >= 6) revert InvalidSelection();
            if ((dice.selectedMask & (1 << index)) != 0)
                revert DiceAlreadySelected();
        }

        // Calculate score for this selection
        uint256 score = _calculateSelectionScore(
            selectedIndices,
            currentValues
        );
        if (score == 0) revert SelectionMustScorePoints();

        // Update state
        dice.turnScore += uint32(score);

        // Mark dice as selected
        for (uint256 i = 0; i < selectedIndices.length; i++) {
            dice.selectedMask |= uint8(1 << selectedIndices[i]);
        }

        // Update available count
        dice.availableCount -= uint8(selectedIndices.length);

        // Check for hot dice (all 6 dice selected)
        if (dice.availableCount == 0) {
            // Hot dice! Reset for another roll with all 6 dice
            dice.selectedMask = 0;
            dice.availableCount = 6;
            dice.hasRolled = false; // Player must roll again
            hotDiceCounts[msg.sender]++;
        }

        emit DiceSelected(msg.sender, score);
        return score;
    }

    function bank()
        external
        nonReentrant
        onlyCurrentPlayer
        notBeforeGameStart
        notAfterGameOver
    {
        if (!dice.hasRolled) revert MustRollAtLeastOnce();

        // Bank the turn score
        uint256 turnScore = dice.turnScore;
        playerScores[players[currentPlayer]] += turnScore;
        uint256 totalScore = playerScores[players[currentPlayer]];

        emit Banked(msg.sender, turnScore, totalScore);
        if (!finalTurn && totalScore > MAX_SCORE) {
            finalTurn = true;
            finalTurnPlayer = msg.sender;
            emit FinalTurn();
        }

        // Reset for next player
        _nextTurn();
    }

    function _rollAvailableDice() internal view returns (uint8[6] memory) {
        uint8[6] memory values = _unpackDiceValues(dice.values);
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender,
                    dice.turnScore
                )
            )
        );

        // Only roll unselected dice
        for (uint256 i = 0; i < 6; i++) {
            if ((dice.selectedMask & (1 << i)) == 0) {
                // This die is not selected, roll it
                values[i] = uint8((seed >> (i * 8)) % 6) + 1;
            }
            // Selected dice keep their existing values
        }

        return values;
    }

    function _calculateSelectionScore(
        uint8[] calldata indices,
        uint8[6] memory values
    ) internal pure returns (uint256) {
        // Count frequencies of selected dice values
        uint8[7] memory counts; // index 0 unused, 1-6 for die values

        for (uint256 i = 0; i < indices.length; i++) {
            uint8 value = values[indices[i]];
            counts[value]++;
        }

        return _scoreFromCounts(counts);
    }

    function _scoreFromCounts(
        uint8[7] memory counts
    ) internal pure returns (uint256) {
        uint256 score = 0;

        // Check for special combinations first (highest priority)

        // Check for straight (1,2,3,4,5,6) = 150 points
        if (
            counts[1] == 1 &&
            counts[2] == 1 &&
            counts[3] == 1 &&
            counts[4] == 1 &&
            counts[5] == 1 &&
            counts[6] == 1
        ) {
            return 150;
        }

        // Check for two sets of three of a kind = 250 points
        uint8 threeOfAKindCount = 0;
        for (uint8 value = 1; value <= 6; value++) {
            if (counts[value] == 3) {
                threeOfAKindCount++;
            }
        }
        if (threeOfAKindCount == 2) {
            return 250;
        }

        // Check for three pairs = 150 points
        uint8 pairCount = 0;
        for (uint8 value = 1; value <= 6; value++) {
            if (counts[value] == 2) {
                pairCount++;
            }
        }
        if (pairCount == 3) {
            return 150;
        }

        // Check for four of a kind + pair = 150 points
        bool hasFourOfAKind = false;
        bool hasPair = false;
        for (uint8 value = 1; value <= 6; value++) {
            if (counts[value] == 4) {
                hasFourOfAKind = true;
            } else if (counts[value] == 2) {
                hasPair = true;
            }
        }
        if (hasFourOfAKind && hasPair) {
            return 150;
        }

        // Standard scoring for individual combinations
        for (uint8 value = 1; value <= 6; value++) {
            uint8 count = counts[value];
            if (count == 0) continue;

            if (count == 6) {
                // 6 of a kind = 300 points
                score += 300;
            } else if (count == 5) {
                // 5 of a kind = 200 points
                score += 200;
            } else if (count == 4) {
                // 4 of a kind = 100 points
                score += 100;
            } else if (count == 3) {
                // Three of a kind
                if (value == 1) {
                    score += 100; // Three 1s = 100
                } else {
                    score += uint256(value) * 10; // Three of anything else = face value × 10
                }
            } else {
                // Individual dice (1s and 5s only)
                if (value == 1) {
                    score += uint256(count) * 10; // Individual 1s = 10 each
                } else if (value == 5) {
                    score += uint256(count) * 5; // Individual 5s = 5 each
                }
                // Note: Individual 2s, 3s, 4s, 6s don't score unless part of combinations
            }
        }

        return score;
    }

    function _hasAnyScore(uint8[6] memory values) internal view returns (bool) {
        // Check only the newly rolled dice (unselected ones)
        uint8[7] memory counts;
        uint8 newDiceCount = 0;

        for (uint256 i = 0; i < 6; i++) {
            if ((dice.selectedMask & (1 << i)) == 0) {
                // This die was just rolled
                counts[values[i]]++;
                newDiceCount++;
            }
        }

        // Check if any of the newly rolled dice can score
        for (uint8 value = 1; value <= 6; value++) {
            if (counts[value] >= 3) return true; // Three of a kind
            if (value == 1 && counts[1] > 0) return true; // Individual 1s
            if (value == 5 && counts[5] > 0) return true; // Individual 5s
        }

        return false;
    }

    function _farkle(address player) internal {
        farkleCounts[player]++;
        emit Farkled(player);
        _nextTurn();
    }

    function _nextTurn() internal {
        dice = DiceState({
            values: 0,
            selectedMask: 0,
            availableCount: 6,
            turnScore: 0,
            hasRolled: false
        });
        currentPlayer = (currentPlayer + 1) % players.length;
        if (finalTurn && players[currentPlayer] == finalTurnPlayer) {
            _endGame();
        }
    }

    function _endGame() internal {
        uint256 highestScore = 0;
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            delete refundElligble[player];
            uint256 score = playerScores[player];
            if (score > highestScore) {
                highestScore = score;
                winner = player;
            }
        }
        gameEnded = true;
        emit GameOver(winner, highestScore);

        uint256 fee;
        uint256 winnings;
        if (pot > 0) {
            fee = (pot * FEE_BASIS_POINTS) / FEE_DENOMINATOR;
            winnings = pot - fee;
        }

        PlayerResult[] memory results = new PlayerResult[](players.length);
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            results[i] = PlayerResult({
                player: player,
                winner: (player == winner),
                farkleCount: farkleCounts[player],
                hotDiceCount: hotDiceCounts[player],
                wager: entryFee,
                amountWon: (player == winner ? winnings : 0)
            });
        }

        LEADERBOARD.update(results, token, pot);
        if (pot > 0) {
            if (token.isETH()) {
                (bool sent, ) = payable(TREASURY).call{value: fee}("");
                if (!sent) revert FeeTransferError();
            } else if (token.isUSDC()) {
                IERC20(USDC).transfer(TREASURY, fee);
            }
        }
    }

    function _packDiceValues(
        uint8[6] memory values
    ) internal pure returns (uint48) {
        uint48 packed = 0;
        for (uint48 i = 0; i < 6; i++) {
            packed |= uint48(values[i] - 1) << (i * 8);
        }
        return packed;
    }

    function _unpackDiceValues(
        uint48 packed
    ) internal pure returns (uint8[6] memory) {
        uint8[6] memory values;
        for (uint8 i = 0; i < 6; i++) {
            values[i] = uint8(((packed >> (i * 8)) & 0xFF) + 1);
        }
        return values;
    }

    // View functions for game state
    function getCurrentDiceValues() external view returns (uint8[6] memory) {
        return _unpackDiceValues(dice.values);
    }

    function getSelectedMask() external view returns (uint8) {
        return dice.selectedMask;
    }

    function getTurnScore() external view returns (uint32) {
        return dice.turnScore;
    }

    function getAvailableCount() external view returns (uint8) {
        return dice.availableCount;
    }
}
