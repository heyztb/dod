# On-Chain Leaderboard Design Approach

This document outlines the recommended architecture for implementing the Farkle game's on-chain leaderboard.

## Core Requirement

The leaderboard needs to track various player statistics and provide a sorted view (e.g., top 10 players by wins). The primary challenge is designing a system that is both gas-efficient and provides a fast, responsive user experience.

## Option 1: Off-Chain Indexing (Highly Recommended)

This is the standard, most scalable, and cost-effective pattern for on-chain leaderboards.

1.  **On-Chain (Source of Truth):** The `FarkleLeaderboardImpl.sol` smart contract's only job is to be the authoritative source of truth for player stats. It stores data in a simple `mapping(address => Stats)`.
2.  **Events:** When a game concludes, the `FarkleGameImpl` contract calls the leaderboard contract's `updateGameResult` function. This function updates the stats for the players involved and emits an event (e.g., `LeaderboardUpdated`) for each player with their new statistics.
3.  **Off-Chain Service (Indexer):** A separate, off-chain service listens for these `LeaderboardUpdated` events. This service can be a custom backend (e.g., Node.js, Go) or a decentralized indexing protocol like The Graph. It ingests the event data and stores it in a traditional, sortable database (e.g., PostgreSQL, MongoDB).
4.  **Frontend Application:** The dApp's frontend queries this off-chain service via a simple API (e.g., REST or GraphQL) to get a beautifully sorted list of the top players. This data can be displayed instantly without waiting for a blockchain query.

### Why this approach is recommended:

*   **Low Gas Cost:** On-chain operations are limited to simple storage writes (`SSTORE`), which are far cheaper than iterating and sorting arrays in storage.
*   **Fast User Experience:** Leaderboards load instantly from the cached, indexed data provided by the off-chain service.
*   **Flexibility:** You can create many different views of the leaderboard (sort by wins, by net winnings, by win streak, etc.) simply by changing the API queries on the off-chain service. This requires no expensive changes or migrations to the smart contract.
*   **Scalability:** The system can handle a massive number of players and games without a proportional increase in on-chain transaction costs for reading leaderboard data.

## Option 2: On-Chain Sorted Leaderboard (Not Recommended)

This approach involves storing a sorted array of player addresses or structs directly within the smart contract.

### Why this approach is NOT recommended:

*   **Extremely High Gas Costs:** Every time a player's score changes, the contract would need to find their current position, remove them, find their new position, and insert them. This involves re-shuffling elements in a storage array, which is one of the most gas-intensive operations in Solidity. For a popular game, a single leaderboard update could become prohibitively expensive.
*   **High Complexity:** The Solidity code to manage a sorted array is significantly more complex to write, audit for security, and maintain over time.
*   **Limited Scalability:** The gas costs would grow with the number of players on the leaderboard, making it unsustainable for a successful game.

## Recommended `update` Function Signature

To support the off-chain indexing model, the `update` function in the leaderboard contract should accept the complete results of a game.

**Interface (`ILeaderboard.sol`):**
```solidity
function updateGameResult(
    address winner,
    address loser,
    uint256 wager,
    uint256 winnerHotDiceCount,
    uint256 loserHotDiceCount,
    uint256 winnerFarkleCount,
    uint256 loserFarkleCount
) external;
```

**Implementation (`FarkleLeaderboardImpl.sol`):**
```solidity
// Event to be indexed off-chain
event LeaderboardUpdated(address indexed player, Stats stats);

function updateGameResult(...) external override onlyOwner {
    // --- Update Winner ---
    Stats storage winnerStats = leaderboard[winner];
    winnerStats.gamesPlayed++;
    winnerStats.gamesWon++;
    winnerStats.totalWagered += wager;
    winnerStats.totalWon += wager; // Assumes winner takes the pot
    winnerStats.currentWinStreak++;
    // ... update other stats like hot dice, etc. ...

    // --- Update Loser ---
    Stats storage loserStats = leaderboard[loser];
    loserStats.gamesPlayed++;
    loserStats.totalWagered += wager;
    loserStats.currentWinStreak = 0; // Reset streak
    // ... update other stats ...

    // --- Emit Events ---
    // Emit events for both players so the off-chain service can index them
    emit LeaderboardUpdated(winner, winnerStats);
    emit LeaderboardUpdated(loser, loserStats);
}
```

This design provides a robust, scalable, and cost-effective foundation for your on-chain leaderboard.
