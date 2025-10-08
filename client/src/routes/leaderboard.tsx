import { createFileRoute } from "@tanstack/react-router";
import { sdk } from "@farcaster/miniapp-sdk";
import { useEffect, useState } from "react";

export const Route = createFileRoute("/leaderboard")({
  component: Leaderboard,
});

const leaderboardData = [
  {
    rank: 1,
    name: "ALEX_M",
    gamesPlayed: 247,
    winRate: 68,
    highScore: 12450,
    avgScore: 8920,
    totalPoints: 2203240,
  },
  {
    rank: 2,
    name: "JORDAN_K",
    gamesPlayed: 198,
    winRate: 64,
    highScore: 11800,
    avgScore: 8650,
    totalPoints: 1712700,
  },
  {
    rank: 3,
    name: "RILEY_P",
    gamesPlayed: 312,
    winRate: 61,
    highScore: 13200,
    avgScore: 8340,
    totalPoints: 2602080,
  },
  {
    rank: 4,
    name: "CASEY_L",
    gamesPlayed: 156,
    winRate: 59,
    highScore: 10950,
    avgScore: 8120,
    totalPoints: 1266720,
  },
  {
    rank: 5,
    name: "MORGAN_T",
    gamesPlayed: 189,
    winRate: 57,
    highScore: 11400,
    avgScore: 7980,
    totalPoints: 1508220,
  },
  {
    rank: 6,
    name: "TAYLOR_R",
    gamesPlayed: 143,
    winRate: 55,
    highScore: 10200,
    avgScore: 7750,
    totalPoints: 1108250,
  },
  {
    rank: 7,
    name: "DREW_S",
    gamesPlayed: 201,
    winRate: 53,
    highScore: 10800,
    avgScore: 7620,
    totalPoints: 1531620,
  },
  {
    rank: 8,
    name: "AVERY_W",
    gamesPlayed: 167,
    winRate: 51,
    highScore: 9950,
    avgScore: 7480,
    totalPoints: 1249160,
  },
];

function Leaderboard() {
  const topThree = leaderboardData.slice(0, 3);
  const restOfLeaderboard = leaderboardData.slice(3);
  const [inMiniApp, setInMiniApp] = useState(false);

  useEffect(() => {
    (async () => {
      setInMiniApp(await sdk.isInMiniApp());
      if (inMiniApp) {
        sdk.actions.ready();
      }
    })();
  }, [inMiniApp]);

  if (!inMiniApp) {
    return (
      <div className="max-w-xl mx-auto flex flex-col gap-6 items-center justify-center min-h-screen">
        <h1 className="text-3xl font-bold">Welcome to Dice of Destiny!</h1>
        <p>Please use the Farcaster or Base app miniapp to continue.</p>
      </div>
    );
  }
  return (
    <div className="min-h-screen flex flex-col">
      {/* Main Content */}
      <main className="flex-1 flex flex-col px-4 py-8 overflow-y-auto">
        {/* Title */}
        <div className="mb-8">
          <h1 className="text-5xl font-black leading-none mb-2">
            LEADER
            <br />
            BOARD
          </h1>
          <p className="text-black/90 text-sm font-medium tracking-wide">
            TOP PLAYERS BY WIN RATE
          </p>
        </div>

        <div className="mb-12">
          <div className="flex items-end justify-center gap-2 mb-8">
            {/* 2nd Place - Left */}
            <div className="flex-1 flex flex-col items-center">
              <div className="text-4xl font-black mb-2">2</div>
              <div
                className="w-full border-2 border-black p-3 text-center"
                style={{ height: "140px" }}
              >
                <div className="text-lg font-bold mb-1">{topThree[1].name}</div>
                <div className="text-3xl font-black mb-1">
                  {topThree[1].winRate}%
                </div>
                <div className="text-[10px] text-black/60 font-medium tracking-wider">
                  WIN RATE
                </div>
              </div>
            </div>

            {/* 1st Place - Center (Tallest) */}
            <div className="flex-1 flex flex-col items-center">
              <div className="text-5xl font-black mb-2">1</div>
              <div
                className="w-full border-2 border-black p-3 text-center"
                style={{ height: "180px" }}
              >
                <div className="text-lg font-bold mb-1">{topThree[0].name}</div>
                <div className="text-4xl font-black mb-1">
                  {topThree[0].winRate}%
                </div>
                <div className="text-[10px] text-black/60 font-medium tracking-wider">
                  WIN RATE
                </div>
              </div>
            </div>

            {/* 3rd Place - Right */}
            <div className="flex-1 flex flex-col items-center">
              <div className="text-3xl font-black mb-2">3</div>
              <div
                className="w-full border-2 border-black p-3 text-center"
                style={{ height: "100px" }}
              >
                <div className="text-base font-bold mb-1">
                  {topThree[2].name}
                </div>
                <div className="text-2xl font-black mb-1">
                  {topThree[2].winRate}%
                </div>
                <div className="text-[10px] text-black/60 tracking-wider">
                  WIN RATE
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-2 text-center text-xs">
            {topThree.map((player) => (
              <div key={player.rank} className="border-2 border-black/80 p-2">
                <div className="font-bold mb-1">{player.gamesPlayed}</div>
                <div className="text-[9px] text-black/90 tracking-wider">
                  GAMES
                </div>
                <div className="font-bold mt-2 mb-1">
                  {player.highScore.toLocaleString()}
                </div>
                <div className="text-[9px] text-black/90 tracking-wider">
                  HIGH
                </div>
              </div>
            ))}
          </div>
        </div>

        {restOfLeaderboard.length > 0 && (
          <div className="space-y-2">
            <div className="text-xs font-bold tracking-widest text-black/90 mb-4">
              REST OF LEADERBOARD
            </div>
            {restOfLeaderboard.map((player) => (
              <div
                key={player.rank}
                className="border-2 border-black/80 bg-white/5 p-3 flex items-center justify-between"
              >
                <div className="flex items-center gap-3">
                  <span className="text-xl font-black text-black/90 w-8">
                    #{player.rank}
                  </span>
                  <div>
                    <div className="text-sm font-bold tracking-wide">
                      {player.name}
                    </div>
                    <div className="text-[10px] text-black/90">
                      {player.gamesPlayed} games •{" "}
                      {player.highScore.toLocaleString()} high
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-xl font-black">{player.winRate}%</div>
                  <div className="text-[9px] text-white/60 tracking-wider">
                    WIN
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Bottom Spacer */}
        <div className="h-8" />
      </main>
    </div>
  );
}
