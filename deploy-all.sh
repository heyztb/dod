#!/bin/bash

# This script deploys the entire Farkle contract system.
# It requires `forge`, `jq`, and `sed` to be installed.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# You can change these values to target different networks or use different wallets.
RPC_URL=${RPC_URL:-"http://127.0.0.1:8545"} # Default to local anvil
VRF_COORDINATOR_BASE_MAINNET="0xd5D517aBE5cF79B7e95eC98dB0f0277788aFF634"
VRF_COORDINATOR_BASE_SEPOLIA="0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE"

# --- Deployment Steps ---

echo "🚀 Starting full system deployment..."

#1 . Deploy treasury
echo "\n[1/6] Deploying Treasury..."
TREASURY_OUTPUT=$(forge script src/contracts/script/DeployTreasury.s.sol --rpc-url $RPC_URL --broadcast)
TREASURY_ADDRESS=$(echo "$TREASURY_OUTPUT" | grep "FarkleTreasury deployed at:" | sed 's/.*: //')
if [ -z "$TREASURY_ADDRESS" ]; then
    echo "❌ Failed to capture Treasury address."
    exit 1
fi
echo "✅ Treasury deployed at: $TREASURY_ADDRESS"


# 2. Deploy FarkleGameBeacon
echo "\n[2/6] Deploying FarkleGameBeacon..."
GAME_BEACON_OUTPUT=$(forge script src/contracts/script/DeployFarkleGameBeacon.s.sol --rpc-url $RPC_URL --broadcast --sig "run(address,address)" )
GAME_BEACON_ADDRESS=$(echo "$GAME_BEACON_OUTPUT" | grep "UpgradeableBeacon deployed at:" | sed 's/.*: //')
if [ -z "$GAME_BEACON_ADDRESS" ]; then
    echo "❌ Failed to capture Game Beacon address."
    exit 1
fi
echo "✅ FarkleGameBeacon deployed at: $GAME_BEACON_ADDRESS"

# 3. Deploy FarkleRoomBeacon
echo "\n[3/6] Deploying FarkleRoomBeacon..."
ROOM_BEACON_OUTPUT=$(forge script src/contracts/script/DeployFarkleRoomBeacon.s.sol --rpc-url $RPC_URL --broadcast)
ROOM_BEACON_ADDRESS=$(echo "$ROOM_BEACON_OUTPUT" | grep "FarkleRoomBeacon deployed at:" | sed 's/.*: //')
if [ -z "$ROOM_BEACON_ADDRESS" ]; then
    echo "❌ Failed to capture Room Beacon address."
    exit 1
fi
echo "✅ FarkleRoomBeacon deployed at: $ROOM_BEACON_ADDRESS"

# 4. Deploy Factories and Leaderboard
echo "\n[4/6] Deploying Factories and Leaderboard..."
SYSTEM_OUTPUT=$(forge script src/contracts/script/DeployFactoriesAndLeaderboard.s.sol --rpc-url $RPC_URL --broadcast --sig "run(address,address)" $GAME_BEACON_ADDRESS $ROOM_BEACON_ADDRESS)

# 5. Capture deployed addresses from the final script
echo "\n[5/6] Capturing final contract addresses..."
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

# 6. (Optional) Generate a JSON file with the deployed addresses for your frontend
echo "\n[6/6] Generating address configuration file..."
cat > deployed-addresses.json << EOL
{
  "gameBeacon": "$GAME_BEACON_ADDRESS",
  "roomBeacon": "$ROOM_BEACON_ADDRESS",
  "gameFactory": "$GAME_FACTORY_ADDRESS",
  "roomFactory": "$ROOM_FACTORY_ADDRESS",
  "leaderboard": "$LEADERBOARD_PROXY_ADDRESS",
  "treasury": "$TREASURY_ADDRESS"
}
EOL

echo "\n🎉 Deployment complete! Address configuration written to deployed-addresses.json"
