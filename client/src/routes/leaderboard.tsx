import { createFileRoute } from "@tanstack/react-router";
import { LeaderboardEntry } from "@/components/LeaderboardEntry";
import { sdk } from "@farcaster/miniapp-sdk";
import { useEffect, useState } from "react";

export const Route = createFileRoute("/leaderboard")({
  component: Leaderboard,
});

function Leaderboard() {
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
        <p>
          Please open this app in the Farcaster or Base App Mini App to
          continue.
        </p>
      </div>
    );
  }
  return (
    <div className="">
      <div className="inline-flex w-full justify-around p-2">
        <p className="text-xl text-black underline underline-offset-auto">
          Player
        </p>
        <p className="text-xl text-black underline underline-offset-auto">
          Games Won
        </p>
      </div>
      <div className="max-w-xl flex flex-col m-2 gap-3 min-h-screen overflow-y-auto">
        <LeaderboardEntry
          position={1}
          username="heyztb.eth"
          address="0xE9821d00E727E9F87B8c18910575c0b08640e670"
          fid={979284}
          pfpUrl="https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/f1449280-f354-4892-567e-5d9c29cb4d00/rectcrop3"
          gamesWon={271}
        />
        <LeaderboardEntry
          position={2}
          username="heyztb.eth"
          address="0xE9821d00E727E9F87B8c18910575c0b08640e670"
          fid={979284}
          pfpUrl="https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/f1449280-f354-4892-567e-5d9c29cb4d00/rectcrop3"
          gamesWon={249}
        />
        <LeaderboardEntry
          position={3}
          username="heyztb.eth"
          address="0xE9821d00E727E9F87B8c18910575c0b08640e670"
          fid={979284}
          pfpUrl="https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/f1449280-f354-4892-567e-5d9c29cb4d00/rectcrop3"
          gamesWon={173}
        />
      </div>
    </div>
  );
}
