import { useEffect, useMemo, useState } from "react";
import mockFinishedGames, { FinishedGame } from "../lib/mockFinishedGames";

type Props = { games?: FinishedGame[]; title?: string; maxItems?: number };

// TODO: Use real data from Valkey pub/sub
export default function FinishedGamesList({
  games: propGames,
  title = "Recent Finished Games",
  maxItems = 6,
}: Props) {
  const [loading, setLoading] = useState(true);
  const games = useMemo(() => propGames ?? mockFinishedGames, [propGames]);

  useEffect(() => {
    const t = setTimeout(() => setLoading(false), 600);
    return () => clearTimeout(t);
  }, []);

  return (
    <div className="mt-6 w-full rounded-2xl bg-white/80 p-4 shadow-sm backdrop-blur-sm">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
        <span className="text-sm text-gray-500">Live</span>
      </div>

      <div className="mt-3 space-y-3">
        {loading ? (
          <div className="space-y-2">
            <div className="h-8 w-full animate-pulse rounded bg-gray-200"></div>
            <div className="h-8 w-full animate-pulse rounded bg-gray-200"></div>
          </div>
        ) : (
          games.slice(0, maxItems).map((g) => {
            const prizePool = g.players.reduce((s, p) => s + p.entry.amount, 0);
            const winner = g.players.find((p) => p.id === g.winnerId);
            return (
              <div
                key={g.id}
                className="rounded p-3 hover:bg-gray-50 transition-colors"
              >
                <div className="flex items-start justify-between">
                  <div>
                    <div className="text-sm font-medium text-gray-900">
                      Game {g.gameId}
                    </div>
                    <div className="text-xs text-gray-500">
                      {g.players.length} players •{" "}
                      {new Date(g.timestamp).toLocaleTimeString()}
                    </div>

                    <div className="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-2">
                      {g.players.map((p) => (
                        <div key={p.id} className="flex items-center gap-3">
                          <div>
                            <div className="text-sm text-gray-900">
                              <span className="text-xs text-gray-700">
                                {p.farcasterName ?? p.ens ?? "unknown"}
                              </span>
                            </div>
                            <div className="text-xs text-gray-400">
                              {p.entry.amount} {p.entry.symbol}
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="text-right">
                    <div className="text-sm text-gray-500">Prize pool</div>
                    <div className="text-lg font-semibold text-green-600">
                      {Number(prizePool.toFixed(2))}{" "}
                      {g.players[0]?.entry.symbol}
                    </div>
                    {winner ? (
                      <div className="text-xs text-gray-700 mt-2">
                        Winner:{" "}
                        <span className="text-xs text-gray-500">
                          {winner.farcasterName ?? winner.ens ?? ""}
                        </span>
                      </div>
                    ) : null}
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
