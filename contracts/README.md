# Farkle Contracts (overview)

This folder contains the smart contract implementation and deployment scripts for "Farkle" — a multiplayer dice game. The codebase uses Foundry for compilation, testing, and scripting. The contracts are organized to support upgradeability, gas-efficient deployments, and a canonical game factory that mints game instances.

                                 ┌────────────────────────┐
                                 │                        │
                             ┌───│      Game Factory      │─────┐
                             │   │                        │     │
                             │   └────────────────────────┘     │
                             │                │                 │
                             │                │                 │
                             ▼                │                 ▼
                      ┌────────────┐   ┌──────▼─────┐    ┌────────────┐
                      │            │   │            │    │            │
                      │    Game    │   │    Game    │    │    Game    │
                      │            │   │            │    │            │
                      └────────────┘   └────────────┘    └────────────┘
                             │                │                 │
                             │                │                 │
                             └────────────────┼─────────────────┘
                                              │
                                              ▼
                                  ┌───────────────────────┐
                                  │                       │
                                  │     Beacon Proxy      │
                                  │                       │
                                  └───────────────────────┘
                                              │
                                              │
                                              │
                                              │
                                              ▼
                                  ┌───────────────────────┐
                                  │                       │
                                  │  Game Implementation  │
                                  │       Contract        │
                                  │                       │
                                  └───────────────────────┘

## Game summary

Farkle is a turn-based dice game where players roll six dice trying to make scoring combinations. Players may bank points or risk another roll; certain rolls (a "Farkle") score zero and end the player's turn. The on-chain implementation models games as independent contracts so each match's state (players, scores, current turn, rolled dice, etc.) is isolated and auditable.

This repository implements an upgradeable game implementation and a factory that deploys new game instances (proxied via a beacon pattern) so game logic can be upgraded without replacing existing game state.

## What each contract/directory does

    - `src/factory/`
      - `FarkleGameFactory.sol` — Factory that deploys new game proxies and registers games. The factory is the primary entry point for creating matches and can enforce global rules (fees, max players, whitelists).

    - `src/impl/`
      - `FarkleGameImpl.sol` — Core game implementation with scoring, turn logic, and state management.
      - `FarkleLeaderboardImpl.sol` — Optional leaderboard logic (aggregate scores, leaderboard maintenance).

    - `src/interface/`
      - `IFarkleGameFactory.sol` — Factory interface.
      - `IFarkleGame.sol` — Game interface describing external ABI for game actions.
      - `IFarkleLeaderboard.sol` — Leaderboard interface.

    - `src/library/`
      - `Token.sol` — Utility token/encoding helpers used across contracts.

    - `src/UpgradeableBeacon.yul`
      - Minimal, gas-optimized beacon implementation used to point proxies to the current implementation.

    - `script/`
      - Forge script used to deploy the beacon, implementations, and factory.
      - Upgrades must be done manually through the Safe web UI

    - `test/`
      - Foundry tests that validate gameplay, scoring, and upgrade scenarios.

    - `cache/`, `lib/` and vendor folders
      - Third-party libraries and cached dependencies used for development and testing.

## Design / Rationale

    - Upgradeability
      - Using a beacon + proxy pattern allows the project to upgrade game logic without redeploying each game instance. Proxies keep state while the beacon's implementation pointer can be changed to a new logic contract.

    - Factory + proxies
      - Deploying thin proxy instances via the factory is far more gas efficient than deploying a full implementation per game. The factory also serves as an on-chain registry and can apply global rules.

    - Libraries & interfaces
      - Libraries reduce bytecode duplication. Interfaces make boundaries explicit and enable multiple implementations to be swapped behind the same ABI.

## Tests and upgrade checks

Tests include:

    - Game lobby mechanics (joining, paying entry fee, leaving, getting refund)
    - Ownership assumptions (for the asm block in FarkleGameImpl.initialize)
    - Gameplay scenarios (roll/score/bank/turn rotation)
    - Farkle detection and scoring edge cases
    - Upgrade safety: ensure storage layout compatibility and validate that existing game state behaves correctly after an implementation upgrade.
