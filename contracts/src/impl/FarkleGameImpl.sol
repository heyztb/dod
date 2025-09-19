// SPDX-License-Identifier: AGPL-3.0-only
/// @title FarkleGameImpl.sol
/// @author heyztb.eth
pragma solidity ^0.8.30;

import {Initializable} from "solady/utils/Initializable.sol";
import {IFarkleGame} from "src/interface/IFarkleGame.sol";
import {IFarkleLeaderboard, PlayerResult} from "src/interface/IFarkleLeaderboard.sol";
import {IFarkleTreasury} from "src/interface/IFarkleTreasury.sol";
import {VRFConsumerBaseV2Plus} from "chainlink/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "chainlink/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract FarkleGameImpl is IFarkleGame, Initializable, VRFConsumerBaseV2Plus {
    string public constant VERSION = "v1";
    // TODO: Update these addresses before deployment
    IFarkleLeaderboard public constant leaderboard =
        IFarkleLeaderboard(address(0x0000000000000000));
    IFarkleTreasury public constant treasury =
        IFarkleTreasury(address(0x0000000000000000));
    bool public startable = true;
    address public host;
    address[] public players;
    uint256 public currentPlayer;
    address public token;
    uint256 public entryFee;
    mapping(address => uint256) public playerScores;
    uint256 public constant MAX_SCORE = 10_000;
    address public finalTurnPlayer;
    address public winner;
    bool public finalTurn = false;
    bool public gameEnded = false;
    mapping(address => uint256) public farkleCounts;
    mapping(address => uint256) public hotDiceCounts;
    uint256 public constant feeBasisPoints = 250;
    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 s_subscriptionId =
        110332509415864652465086222220959657000163978298414210005002692430465200668803;
    bytes32 s_keyHash =
        0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71;
    uint32 s_callbackGasLimit = 150000;
    uint16 s_requestConfirmations = 1;
    mapping(uint256 => address) public s_requestToPlayer;
    mapping(address => bool) public s_rollInProgress;

    struct DiceState {
        uint48 values; // Current dice values (1-6 each)
        uint8 selectedMask; // Bit mask for selected dice (1 = selected, 0 = available)
        uint8 availableCount; // Number of dice available to roll
        uint32 turnScore; // Points accumulated this turn
        bool hasRolled; // Whether player has rolled this turn
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
    event PlayerWon(address indexed player, address token, uint256 amount);
    event GameOver(address indexed winner, uint256 score);

    error AlreadyJoined();
    error GameFull();
    error NotInGame();
    error MustBeHost();
    error GameNotStarted();
    error GameAlreadyStarted();
    error InvalidToken();
    error InvalidTreasury();
    error NotCurrentPlayer();
    error GameAlreadyOver();
    error InvalidSelection();
    error MustRollFirst();
    error RollInProgress();
    error DiceAlreadySelected();
    error NoScoringDice();
    error NoDiceAvailable();
    error MustSelectAtLeastOneDie();
    error SelectionMustScorePoints();
    error MustRollAtLeastOnce();
    error NotEnoughEther();
    error WantERC20NotETH();
    error ERC20TransferFromError(address player);
    error ERC20TransferError(address player);
    error FeeTransferError();
    error RefundTransferError();
    error WinnerTransferError();

    modifier onlyCurrentPlayer() {
        if (msg.sender != players[currentPlayer]) revert NotCurrentPlayer();
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

    modifier onlyHost() {
        if (msg.sender != host) revert MustBeHost();
        _;
    }

    constructor(
        address _vrfCoordinator
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        if (_vrfCoordinator == address(0)) revert ZeroAddress();
        _disableInitializers();
    }

    function initialize(
        address _token,
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
        transferOwnership(address(0));
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
        require(player != address(0), "Request not found");
        s_rollInProgress[player] = false;
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

        // Check for straight (1,2,3,4,5,6) = 1500 points
        if (
            counts[1] == 1 &&
            counts[2] == 1 &&
            counts[3] == 1 &&
            counts[4] == 1 &&
            counts[5] == 1 &&
            counts[6] == 1
        ) {
            return 1500;
        }

        // Check for two sets of three of a kind = 2500 points
        uint8 threeOfAKindCount = 0;
        for (uint8 value = 1; value <= 6; value++) {
            if (counts[value] == 3) {
                threeOfAKindCount++;
            }
        }
        if (threeOfAKindCount == 2) {
            return 2500;
        }

        // Check for three pairs = 1500 points
        uint8 pairCount = 0;
        for (uint8 value = 1; value <= 6; value++) {
            if (counts[value] == 2) {
                pairCount++;
            }
        }
        if (pairCount == 3) {
            return 1500;
        }

        // Check for four of a kind + pair = 1500 points
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
            return 1500;
        }

        // Standard scoring for individual combinations
        for (uint8 value = 1; value <= 6; value++) {
            uint8 count = counts[value];
            if (count == 0) continue;

            if (count == 6) {
                // 6 of a kind = 3000 points
                score += 3000;
            } else if (count == 5) {
                // 5 of a kind = 2000 points
                score += 2000;
            } else if (count == 4) {
                // 4 of a kind = 1000 points
                score += 1000;
            } else if (count == 3) {
                // Three of a kind
                if (value == 1) {
                    score += 1000; // Three 1s = 1000
                } else {
                    score += uint256(value) * 100; // Three of anything else = face value × 100
                }
            } else {
                // Individual dice (1s and 5s only)
                if (value == 1) {
                    score += uint256(count) * 100; // Individual 1s = 100 each
                } else if (value == 5) {
                    score += uint256(count) * 50; // Individual 5s = 50 each
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
        gameEnded = true;

        uint256 highestScore = 0;
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 score = playerScores[player];
            if (score > highestScore) {
                highestScore = score;
                winner = player;
            }
        }

        PlayerResult[] memory results = new PlayerResult[](players.length);
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            results[i] = PlayerResult({
                player: player,
                winner: (player == winner),
                farkleCount: farkleCounts[player],
                hotDiceCount: hotDiceCounts[player],
                wager: entryFee
            });
        }

        uint256 pot;
        uint256 winnings;
        if (entryFee > 0) {
            if (token == address(0)) {
                pot = address(this).balance;
                uint256 feeAmount = (pot * feeBasisPoints) / FEE_DENOMINATOR;
                winnings = pot - feeAmount;
                (bool feeSentSuccessfully, ) = payable(address(treasury)).call{
                    value: feeAmount
                }("");
                if (!feeSentSuccessfully) {
                    revert FeeTransferError();
                }

                (bool winningsSentSuccesfully, ) = payable(winner).call{
                    value: winnings
                }("");
                if (!winningsSentSuccesfully) {
                    revert WinnerTransferError();
                }
            } else {
                try IERC20(token).balanceOf(address(this)) returns (
                    uint256 _pot
                ) {
                    pot = _pot;
                } catch {
                    revert InvalidToken();
                }
                uint256 feeAmount = (pot * feeBasisPoints) / FEE_DENOMINATOR;
                winnings = pot - feeAmount;
                try
                    IERC20(token).transfer(address(treasury), feeAmount)
                returns (bool feeSentSuccessfully) {
                    if (!feeSentSuccessfully) revert FeeTransferError();
                } catch {
                    revert FeeTransferError();
                }

                try IERC20(token).transfer(winner, winnings) returns (
                    bool winningsSentSuccesfully
                ) {
                    if (!winningsSentSuccesfully) revert WinnerTransferError();
                } catch {
                    revert WinnerTransferError();
                }
            }

            leaderboard.update(results, token, pot);
            emit PlayerWon(winner, token, winnings);
        } else {
            leaderboard.update(results, address(0), 0);
            emit PlayerWon(winner, address(0), 0);
        }
        emit GameOver(winner, highestScore);
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

    function join() external payable notAfterGameStart {
        if (players.length == 4) {
            revert GameFull();
        }

        if (entryFee > 0) {
            if (token == address(0)) {
                if (msg.value != entryFee) revert NotEnoughEther();
            } else {
                if (msg.value != 0) revert WantERC20NotETH();
                try
                    IERC20(token).transferFrom(
                        msg.sender,
                        address(this),
                        entryFee
                    )
                returns (bool success) {
                    if (!success) revert ERC20TransferFromError(msg.sender);
                } catch {
                    revert ERC20TransferFromError(msg.sender);
                }
            }
        }

        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                revert AlreadyJoined();
            }
        }
        players.push(msg.sender);
        if (players.length == 1) {
            host = msg.sender;
        }
        emit PlayerJoined(msg.sender);
    }

    function leave() external notAfterGameStart {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                // if this is not the last player
                if (i < players.length - 1) {
                    // swap them with the last player
                    players[i] = players[players.length - 1];
                    // additionally, if the player leaving is the host,
                    // assign the host role to the player that takes their place
                    if (host == msg.sender) {
                        host = players[i];
                    }
                }
                players.pop();
                if (entryFee > 0) {
                    if (token == address(0)) {
                        (bool refundSentSuccessfully, ) = payable(msg.sender)
                            .call{value: entryFee}("");
                        if (!refundSentSuccessfully) {
                            revert RefundTransferError();
                        }
                    } else {
                        try
                            IERC20(token).transfer(msg.sender, entryFee)
                        returns (bool success) {
                            if (!success) revert ERC20TransferError(msg.sender);
                        } catch {
                            revert ERC20TransferError(msg.sender);
                        }
                    }
                }
                emit PlayerLeft(msg.sender);
                if (players.length == 0) {
                    host = address(0);
                    startable = false;
                    gameEnded = true;
                    emit GameClosed();
                }
                return;
            }
        }
        revert NotInGame();
    }

    function startGame() external notAfterGameStart onlyHost {
        startable = false;
        emit GameStarted();
    }
}
