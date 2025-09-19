import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/leaderboard")({
  component: Leaderboard,
});

function Leaderboard() {
  return (
    <div className="max-w-xl mx-auto flex flex-col gap-6 items-center justify-center min-h-screen">
      <h1 className="text-2xl font-bold">Leaderboard</h1>
      <p>Leaderboard placeholder. Top scores will be shown here.</p>
    </div>
  );
}
