# shutdown

heyztb: write a note for future me talking about a coordinated vote mechanism to end a game early and refund all players, as well as an emergency shut off mechanism that only I can call that does the same thing

GitHub Copilot: I'll write a concise, practical design note you can paste into the repo (e.g., as `NOTES/VOTE_SHUTDOWN.md`) describing a coordinated-vote early-termination + owner-only emergency shutoff, implementation tips, function prototypes, storage layout, security concerns and tests.

## Coordinated vote + owner emergency: design notes

Goal

- Allow the players in a running game to coordinate and vote to end the game early and refund everyone.
- Provide a privileged emergency shutoff callable only by the owner (you) that produces the same final state (safe termination + refunds).
- Avoid expensive on-chain loops; use pull-based refunds and safe state transitions.

High-level approach

- Voting is a snapshot-based vote: when a vote is started we snapshot the set of eligible players (or at least the playerCount / total stake) so the vote result is deterministic and not manipulable by joining/leaving during the vote.
- If the vote reaches a configured threshold within the voting window, the contract transitions to a terminated/refund state.
- When terminated (by vote or by owner emergency), each player's refundable balance is available for withdrawal via a pull-style `withdrawRefund()` function. No mass transfers or iterations.
- Owner emergency shutoff is a single owner-only action that immediately transitions to the same refund state and emits an event.

Key invariants

- Once in Terminated/Refunding state, game actions (play, change state, join) are disabled.
- Each player can withdraw at most their entitled refund (their deposit / stake).
- Voting must be single-active-vote at a time or indexed by `voteId` to avoid concurrency complexity.
- Prevent double voting and replaying votes.

Design choices (pick one)

- Per-player equal-weight voting: every distinct player address = 1 vote. Simpler.
- Weighted-by-stake voting: votes weighted by players' current stake. Use if game has uneven betting amounts.
  Note: Weighted votes require snapshotting stake amounts at vote start.

Player-eligibility and voting weight (project-specific)

- Players can only join before the game starts and never after. That means the set of players for a game is fixed when the game moves from the lobby/Waiting state into Active. Because of this constraint, voting eligibility is simply "all players in the game at start" and there's no need to snapshot dynamically-changing participants during a vote.
- Voting model: per-player weight. Each distinct player address counts as one vote. This is the simplest and fair model given that all players must have joined before the game starts.

Suggested constants

- VOTE_THRESHOLD_PCT: 66 (two-thirds) — fraction of eligible votes required to pass.
- VOTING_PERIOD: e.g., 3 days (in seconds) or number of blocks.
- MIN_QUORUM_PCT: 20 — minimum percent of eligible voters that must participate for the vote to be valid.

Storage layout (example)

- enum State { Waiting, Active, Voting, Terminated }
- State public gameState;
- address public owner; // Ownable pattern
- mapping(address => uint256) public balance; // per-player escrowed amounts (existing game balances)
- uint256 public playerCount; // number of current players (or snapshot value)
- // Voting
  - struct Vote {
    uint256 id;
    uint256 startTime;
    uint256 endTime;
    uint256 votesFor; // aggregated votes (count or stake)
    uint256 votesAgainst;
    uint256 eligibleCountSnapshot; // playerCount or totalStake at vote start
    mapping(address => bool) hasVoted;
    bool finalized;
    }
  - Vote[] public votes;
  - uint256 public activeVoteId; // 0 = none
- // Refund bookkeeping
  - mapping(address => uint256) public withdrawable; // set at termination to player balances
  - mapping(address => bool) public refunded; // or check withdrawable == 0

Events

- event VoteStarted(uint256 indexed voteId, address indexed startedBy, uint256 startTime, uint256 endTime, uint256 eligibleSnapshot);
- event VoteCast(uint256 indexed voteId, address indexed voter, bool support, uint256 weight);
- event VoteFinalized(uint256 indexed voteId, bool passed);
- event EmergencyShutdown(address indexed owner, uint256 timestamp);
- event RefundWithdrawn(address indexed player, uint256 amount);

Function prototypes (Solidity-like pseudocode)

- function startVote() external returns (uint256 voteId)
  - require(gameState == Active, "not active");
  - require(activeVoteId == 0, "vote already active");
  - snapshot eligibleCount (playerCount or totalStake)
  - votes.push(new Vote(...));
  - activeVoteId = votes.length - 1;
  - emit VoteStarted(...);

- function vote(uint256 voteId, bool support) external
  - Vote storage v = votes[voteId];
  - require(block.timestamp <= v.endTime, "vote closed");
  - require(!v.hasVoted[msg.sender], "already voted");
  - weight = choose (1 or balance[msg.sender] if weighted)
  - if (support) v.votesFor += weight else v.votesAgainst += weight;
  - v.hasVoted[msg.sender] = true;
  - emit VoteCast(...);
  - // optional: early finalize on reaching threshold:
  - `if (v.votesFor * 100 >= VOTE_THRESHOLD_PCT * v.eligibleCountSnapshot && v.votesFor + v.votesAgainst >= MIN_QUORUM_PCT * v.eligibleCountSnapshot / 100) finalizeVote(voteId);`

- function finalizeVote(uint256 voteId) public
  - Vote storage v = votes[voteId];
  - require(!v.finalized, "already finalized");
  - require(block.timestamp > v.endTime || early threshold reached)
  - v.finalized = true;
  - activeVoteId = 0;
  - `if (v.votesFor * 100 >= VOTE_THRESHOLD_PCT * v.eligibleCountSnapshot && v.votesFor + v.votesAgainst >= quorum) {`
    // passed
    \_transitionToTerminatedAndPrepareRefunds();
    emit VoteFinalized(voteId, true);
    } else {
    emit VoteFinalized(voteId, false);
    }

- function emergencyShutdown() external onlyOwner
  - require(gameState != Terminated, "already terminated");
  - \_transitionToTerminatedAndPrepareRefunds();
  - emit EmergencyShutdown(msg.sender, block.timestamp);

- internal function \_transitionToTerminatedAndPrepareRefunds()
  - gameState = Terminated;
  - activeVoteId = 0;
  - // Prepare withdrawable without loops:
    - Option A (recommended): Do NOT try to set withdrawable for every player on-chain. Instead keep `balance` as canonical refundable amount and allow players to call withdrawRefund() which transfers their balance and sets balance[msg.sender]=0. This avoids looping over player list.
    - Option B (if you must compute something derived): store a global flag `isRefunding = true` and keep `balance` as refund source.
  - disable other state-changing functions (require !isRefunding in them)

- function withdrawRefund() external nonReentrant
  - amount = balance[msg.sender];
  - require(amount > 0, "no refund");
  - balance[msg.sender] = 0;
  - (bool ok,) = msg.sender.call{value: amount}("");
  - require(ok, "transfer failed");
  - emit RefundWithdrawn(msg.sender, amount);

Why avoid looping over players in refunds (and why it's OK to consider it for small fixed-player games)

- Gas safety and upgradeability: in general, iterating over a dynamic array of player addresses in a public function (for example during finalization to push refunds) is risky because the gas cost grows with the number of players. If the player list were to grow (or if some future game variant allowed more players), a loop could consume more gas than a block gas limit and make the finalization function impossible to call, permanently locking funds.
- Pull vs push: the common safe pattern is a pull-based refund (each player calls `withdrawRefund()` themselves). Pulls shift gas cost to the recipients and avoid expensive on-chain loops that could be unbounded.
- For this project (max 4 players, fixed pre-start): the gas cost of looping over 4 addresses is trivial on today's networks and usually would be fine to implement as an on-chain finalization step that sends refunds to all players in a loop. It's still slightly more complex and introduces a small failure mode: if one of the transfers fails (e.g., non-payable fallback or a reverting recipient), it could break the loop and leave some players unpaid unless you code around it (try/catch or continue-on-failure patterns). Using the pull pattern avoids that edge case entirely because each withdraw is an independent transaction.
- Owner emergency: if you plan to allow the owner to call an emergency shutdown that refunds everyone immediately, looping is convenient and readable for only 4 players. But prefer to implement a loop with safe transfer semantics (e.g., use try/catch on external calls, or send funds via `call` and continue on failure) or simply set a `isRefunding` flag and let players pull their refunds afterward.

Recommendation for this repo

- Since players are fixed at game start and there are at most 4 players, you can choose either approach:
  - Simpler, safe default: implement pull-based refunds only. It's minimal, robust, and avoids tricky failure modes.
  - Practical convenience: implement an owner-only `emergencyShutdownAndRefund()` that loops over the fixed `players[]` array and attempts to send refunds immediately, but also falls back to setting balances so any failed transfers can still be claimed via `withdrawRefund()` later. This hybrid gives the UX of instant refunds while retaining the safety of pull withdrawals.

Small sample hybrid finalization pseudocode

```
function emergencyShutdownAndRefund() external onlyOwner {
  require(gameState != Terminated, "already terminated");
  gameState = Terminated;
  for (uint i = 0; i < players.length; i++) {
    address p = players[i];
    uint256 amt = balance[p];
    if (amt == 0) continue;
    balance[p] = 0; // effects first
    (bool ok, ) = p.call{value: amt}("");
    if (!ok) {
      // credit fallback so player can pull later
      balance[p] = amt;
    }
  }
}
```

This approach attempts immediate refunds but restores the balance on failure so the player can call `withdrawRefund()` later.

Notes about snapshotting & eligibility

- For per-player votes (1 address = 1 vote): snapshot playerCount at vote start and prevent new joins while voting is active OR explicitly state that new joining players are not eligible (i.e., count is snapshot).
- Simpler approach: disallow new joins while vote active (set a `votingLock` flag) to avoid having to snapshot addresses.
- For stake-weighted voting: snapshot each player's stake at start. That is more complex; prefer disallowing stake changes while voting is active (or record each player's stake in a mapping inside the Vote struct at vote start for those who want to vote — too expensive).

Gas & scalability considerations

- Never iterate over dynamic arrays (players) during on-chain finalization; use pull withdrawals.
- Avoid storing a full list of players if not already necessary. If you do store an array of addresses `players[]`, avoid looping over it.
- Keep voting storage minimal: votes track totals, eligible snapshot scalar, and mapping for hasVoted.

Security checklist

- Use ReentrancyGuard for `withdrawRefund`.
- Use checks-effects-interactions: set balance[msg.sender]=0 before external call.
- Use `onlyOwner` (OpenZeppelin Ownable) for emergency shutdown.
- Emit events for all critical transition points.
- Protect against replay double-voting using vote.hasVoted.
- If refunds return ETH, ensure contract holds enough ETH; if using ERC20, use SafeERC20 and transferFrom when collecting stakes initially.
- Consider using pull over push for refunds to avoid gas griefing.

Edge cases & race conditions

- Player tries to join after vote started — either disallow or explicitly not eligible.
- Player that placed stake via a third-party wrapper — ensure `balance` accounts for all deposit paths.
- Vote passes but some player’s balance changed afterwards — snapshoting avoids this.
- If stake-weighted, make sure a participant can’t split their stake across addresses to get multiple votes unless that is acceptable.

Testing plan (unit tests)

- Happy path: start vote → >threshold votes → finalize → players withdraw expected amounts.
- Fail path: start vote → insufficient votes or quorum → finalize fails.
- Double vote attempt should revert.
- New join during vote should be handled according to chosen policy (revert on join or not counted).
- Owner emergency: can only be called by owner and leads to same withdrawable behavior; players withdraw and balances become zero.
- Reentrancy: attempt malicious fallback contract on withdraw should not steal funds.

Developer notes / code patterns

- Prefer OpenZeppelin Ownable + ReentrancyGuard.
- For solidity >=0.8.x you can use unchecked arithmetic where safe; but no need for SafeMath.
- Keep storage variables small and well-named: `isRefunding`, `gameState`, `activeVoteId`.
- If the contract is upgradable/Beacon pattern (looks like project uses upgradeable patterns), ensure initialization and owner invariants remain intact and add access control hooks to the upgradeability admin.

Minimal pseudo-Solidity snippet (quick reference)

```solidity
// state
enum GameState { Waiting, Active, Voting, Terminated }
GameState public gameState;
mapping(address => uint256) public balance;
uint256 public playerCount;
uint256 public constant VOTE_THRESHOLD_PCT = 66;
uint256 public constant MIN_QUORUM_PCT = 20;

struct Vote { uint256 start; uint256 end; uint256 forVotes; uint256 againstVotes; uint256 eligibleSnapshot; mapping(address => bool) voted; bool finalized; }
mapping(uint256 => Vote) votes;
uint256 public activeVoteId;

// key functions: startVote, vote, finalizeVote, emergencyShutdown, withdrawRefund
```

Suggested next steps (practical)

1. Decide voting model: per-player equal-weight vs weighted-by-stake. (If unsure, pick equal-weight; simpler.)
2. Decide snapshot vs lock-joins: either snapshot or disallow joins during an active vote. (I recommend disallow joins while voting is active.)
3. Implement `startVote`, `vote`, `finalizeVote`, `emergencyShutdown`, `withdrawRefund` with tests.
4. Add events and unit tests described above.
5. Run tests and security checks (slither/solhint) if used in your repo.

If you want, I can:

- Draft a concrete Solidity implementation for the game factory or the game contract (choose which contract should contain voting).
- Add unit tests (forge/Foundry or Hardhat) matching your repo's testing framework.
  Which would you prefer me to do next?
