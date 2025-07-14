#!/bin/bash

# This script deploys the entire Farkle contract system.
# It requires `forge`, `jq`, and `sed` to be installed.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# You can change these values to target different networks or use different wallets.
RPC_URL=${RPC_URL:-"http://127.0.0.1:8545"} # Default to local anvil

# --- Deployment Steps ---

echo "🚀 Starting full system deployment..."

# 1. Deploy FarkleGameBeacon
echo "\n[1/5] Deploying FarkleGameBeacon..."
GAME_BEACON_OUTPUT=$(forge script src/contracts/script/DeployFarkleGameBeacon.s.sol --rpc-url $RPC_URL --broadcast)
GAME_BEACON_ADDRESS=$(echo "$GAME_BEACON_OUTPUT" | grep "UpgradeableBeacon deployed at:" | sed 's/.*: //')
if [ -z "$GAME_BEACON_ADDRESS" ]; then
    echo "❌ Failed to capture Game Beacon address."
    exit 1
fi
echo "✅ FarkleGameBeacon deployed at: $GAME_BEACON_ADDRESS"

# 2. Deploy FarkleRoomBeacon
echo "\n[2/5] Deploying FarkleRoomBeacon..."
ROOM_BEACON_OUTPUT=$(forge script src/contracts/script/DeployFarkleRoomBeacon.s.sol --rpc-url $RPC_URL --broadcast)
ROOM_BEACON_ADDRESS=$(echo "$ROOM_BEACON_OUTPUT" | grep "FarkleRoomBeacon deployed at:" | sed 's/.*: //')
if [ -z "$ROOM_BEACON_ADDRESS" ]; then
    echo "❌ Failed to capture Room Beacon address."
    exit 1
fi
echo "✅ FarkleRoomBeacon deployed at: $ROOM_BEACON_ADDRESS"

# 3. Deploy Factories and Leaderboard
echo "\n[3/5] Deploying Factories and Leaderboard..."
SYSTEM_OUTPUT=$(forge script src/contracts/script/DeployFactoriesAndLeaderboard.s.sol --rpc-url $RPC_URL --broadcast --sig "run(address,address)" $GAME_BEACON_ADDRESS $ROOM_BEACON_ADDRESS)

# 4. Capture deployed addresses from the final script
echo "\n[4/5] Capturing final contract addresses..."
GAME_FACTORY_ADDRESS=$(echo "$SYSTEM_OUTPUT" | grep "Deploying FarkleGameFactory at:" | sed 's/.*: //')
ROOM_FACTORY_ADDRESS=$(echo "$SYSTEM_OUTPUT" | grep "Deploying FarkleRoomFactory at:" | sed 's/.*: //')
LEADERBOARD_PROXY_ADDRESS=$(echo "$SYSTEM_OUTPUT" | grep "Deploying FarkleLeaderboardProxy at:" | sed 's/.*: //')

if [ -z "$GAME_FACTORY_ADDRESS" ] || [ -z "$ROOM_FACTORY_ADDRESS" ] || [ -z "$LEADERBOARD_PROXY_ADDRESS" ]; then
    echo "❌ Failed to capture one or more system contract addresses."
    exit 1
fi

echo "✅ FarkleGameFactory deployed at: $GAME_FACTORY_ADDRESS"
echo "✅ FarkleRoomFactory deployed at: $ROOM_FACTORY_ADDRESS"
echo "✅ FarkleLeaderboardProxy deployed at: $LEADERBOARD_PROXY_ADDRESS"

# 5. (Optional) Generate a JSON file with the deployed addresses for your frontend
echo "\n[5/5] Generating address configuration file..."
cat > deployed-addresses.json << EOL
{
  "gameBeacon": "$GAME_BEACON_ADDRESS",
  "roomBeacon": "$ROOM_BEACON_ADDRESS",
  "gameFactory": "$GAME_FACTORY_ADDRESS",
  "roomFactory": "$ROOM_FACTORY_ADDRESS",
  "leaderboard": "$LEADERBOARD_PROXY_ADDRESS"
}
EOL

echo "\n🎉 Deployment complete! Address configuration written to deployed-addresses.json"
