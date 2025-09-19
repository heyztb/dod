import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/play")({
  component: Play,
});

function Play() {
  return (
    <div className="max-w-xl mx-auto flex flex-col gap-6 items-center justify-center min-h-screen">
      <h1 className="text-2xl font-bold">Play</h1>
      <p>Game page placeholder. Start a new game here.</p>
    </div>
  );
}
