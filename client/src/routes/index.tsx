import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { sdk } from "@farcaster/miniapp-sdk";
import { hcWithType } from "server/src/client";
import { type MeResponse } from "shared";
import { Button } from "@/components/ui/button";
import { DiceIcon } from "@/components/DiceIcon";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useQuery } from "@tanstack/react-query";
import { Badge } from "@/components/ui/badge";
import { Spinner } from "@/components/ui/spinner";

const client = hcWithType("/");
export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  const [inMiniApp, setInMiniApp] = useState(false);
  const [showRules, setShowRules] = useState(false);
  const { data, isError, error, isSuccess } = useQuery({
    queryKey: ["user"],
    queryFn: fetchUser,
  });
  useEffect(() => {
    (async () => {
      if (isError) {
        console.error("error fetching user data", error);
      }

      setInMiniApp(await sdk.isInMiniApp());
      if (inMiniApp) {
        sdk.actions.ready();
      }
    })();
  }, [inMiniApp, isSuccess, isError, error]);

  if (!inMiniApp) {
    return (
      <div className="max-w-xl mx-auto flex flex-col gap-6 items-center justify-center min-h-screen">
        <h1 className="text-3xl font-bold">Welcome to Dice of Destiny!</h1>
        <p>Please use the Farcaster or Base app miniapp to continue.</p>
      </div>
    );
  }

  return (
    <>
      {data ? (
        <main className="min-h-screen bg-background text-foreground flex flex-col overflow-y-auto">
          {/* Hero Section */}
          <section className="flex-1 flex flex-col justify-center items-center px-6 relative">
            {/* Geometric Dice Element */}
            <div className="absolute top-1/4 right-8 opacity-20">
              <DiceIcon size={120} />
            </div>

            {/* Main Heading */}
            <h1 className="text-[72px] leading-[0.9] font-bold tracking-tight text-balance mb-8 relative z-10">
              Roll.
              <br />
              Risk.
              <br />
              Win.
            </h1>

            {/* Subheading */}
            <p className="text-base text-muted-foreground max-w-[280px] text-center text-balance mb-12 relative z-10">
              The classic dice game of chance and strategy. Push your luck or
              play it safe.
            </p>

            {/* CTA Button */}
            <Link to="/play" className="w-full max-w-[280px]">
              <Button
                size="lg"
                className="w-full max-w-[280px] h-14 text-base font-bold bg-accent hover:bg-accent/90 hover:cursor-pointer text-accent-foreground relative z-10"
              >
                START GAME
              </Button>
            </Link>

            {/* Secondary Action */}
            <button
              onClick={() => {
                setShowRules(true);
              }}
              className="mt-6 text-sm font-mono tracking-wider text-muted-foreground hover:text-foreground hover:cursor-pointer transition-colors relative z-10"
            >
              HOW TO PLAY
            </button>
          </section>

          <Dialog open={showRules} onOpenChange={setShowRules}>
            <DialogContent className="max-w-[340px] bg-background border-2 border-foreground p-0 gap-0">
              <DialogHeader className="p-6 pb-4 border-b-2 border-foreground">
                <DialogTitle className="text-2xl font-bold tracking-tight">
                  HOW TO PLAY
                </DialogTitle>
              </DialogHeader>

              <div className="p-6 space-y-6 max-h-[400px] overflow-y-auto">
                {/* Objective */}
                <div>
                  <h3 className="text-sm font-mono tracking-wider mb-2 text-foreground">
                    OBJECTIVE
                  </h3>
                  <p className="text-sm leading-relaxed text-muted-foreground">
                    Be the first player to score 1,000 points by rolling scoring
                    combinations.
                  </p>
                </div>

                {/* Gameplay */}
                <div>
                  <h3 className="text-sm font-mono tracking-wider mb-2 text-foreground">
                    GAMEPLAY
                  </h3>
                  <ol className="space-y-2 text-sm text-muted-foreground leading-relaxed list-decimal list-inside">
                    <li>Roll all six dice</li>
                    <li>Set aside scoring dice of your choosing</li>
                    <li>Choose to bank points or roll remaining dice</li>
                    <li>
                      If no scoring dice, you Farkle and lose all points for
                      that turn
                    </li>
                  </ol>
                </div>

                {/* Scoring */}
                <div>
                  <h3 className="text-sm font-mono tracking-wider mb-2 text-foreground">
                    SCORING
                  </h3>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Single 1</span>
                      <span className="font-mono font-bold">10</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Single 5</span>
                      <span className="font-mono font-bold">5</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Three 1s</span>
                      <span className="font-mono font-bold">100</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">
                        Three of a kind (2-6)
                      </span>
                      <span className="font-mono font-bold">10 × number</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">
                        Four of a kind
                      </span>
                      <span className="font-mono font-bold">100</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">
                        Five of a kind
                      </span>
                      <span className="font-mono font-bold">200</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">
                        Six of a kind
                      </span>
                      <span className="font-mono font-bold">300</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Three pairs</span>
                      <span className="font-mono font-bold">150</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">
                        Four of a kind + pair
                      </span>
                      <span className="font-mono font-bold">150</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">
                        Two three of a kinds
                      </span>
                      <span className="font-mono font-bold">250</span>
                    </div>
                  </div>
                </div>

                {/* Strategy */}
                <div>
                  <h3 className="text-sm font-mono tracking-wider mb-2 text-foreground">
                    STRATEGY
                  </h3>
                  <p className="text-sm leading-relaxed text-muted-foreground">
                    Balance risk and reward. Push your luck for higher scores,
                    but don't get too greedy or you'll Farkle!
                  </p>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </main>
      ) : (
        <Badge>
          <Spinner />
          Loading user data...
        </Badge>
      )}
    </>
  );
}

const fetchUser = async () => {
  const { token } = await sdk.quickAuth.getToken();
  if (!token) return null;
  const res = await client.api.me.$get(
    {},
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  );
  if (!res.ok) {
    console.error("Failed to fetch user", res);
    return null;
  }
  const data = (await res.json()) as MeResponse;
  return data;
};
