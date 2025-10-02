import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { sdk, Context } from "@farcaster/miniapp-sdk";
import { hcWithType } from "server/src/client";
import { useQuery } from "@tanstack/react-query";
import { type MeResponse } from "shared";
import { Skeleton } from "@/components/ui/skeleton";
import RulesModal from "@/components/RulesModal";
import UserDrawer from "@/components/UserDrawer";
import FinishedGamesList from "@/components/FinishedGamesList";

const client = hcWithType("/api");
export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  const [inMiniApp, setInMiniApp] = useState(false);
  const [showRules, setShowRules] = useState(false);
  const [context, setContext] = useState<Context.MiniAppContext | null>(null);
  const {
    isSuccess,
    isError,
    error,
    data: userData,
  } = useQuery({
    queryKey: ["user"],
    queryFn: fetchUser,
  });
  useEffect(() => {
    (async () => {
      setInMiniApp(await sdk.isInMiniApp());
      if (inMiniApp) {
        if (isError) {
          console.error("Error fetching user:", error);
          return;
        }
        if (isSuccess) {
          setContext(await sdk.context);
          sdk.actions.ready();
        }
      }
    })();
  }, [inMiniApp, error, isError, isSuccess]);

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
    <div className="max-w-sm mx-auto flex flex-col items-center justify-center min-h-screen bg-[#f5f5f5]">
      {userData ? (
        <div className="bg-surface-50-950 min-h-screen bg-gradient-to-br">
          <div className="container mx-auto p-4 pb-20">
            <div className="mb-8 flex items-center justify-end gap-4">
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => setShowRules(true)}
                  className="cursor-pointer flex items-center gap-2 border border-gray-300/50 rounded-sm bg-white/80 p-2 text-gray-700 backdrop-blur-sm transition-all duration-200 "
                  aria-label="View game rules"
                >
                  {/*Somehow this icon is not included in lucide-react. Here it is in SVG form.*/}
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    className="lucide lucide-circle-question-mark-icon lucide-circle-question-mark"
                  >
                    <circle cx="12" cy="12" r="10" />
                    <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                    <path d="M12 17h.01" />
                  </svg>
                  <span className="hidden sm:inline">Rules</span>
                </button>
              </div>
              <UserDrawer context={context} />
            </div>
            <div className="bg-surface-100-900/25 relative overflow-hidden rounded-2xl p-8 backdrop-blur-sm">
              <div
                className="absolute inset-0 opacity-[0.03] dark:opacity-[0.05]"
                style={{
                  backgroundImage:
                    "radial-gradient(circle at 1px 1px, currentColor 1px, transparent 0)",
                  backgroundSize: "20px 20px",
                }}
              ></div>

              <div className="relative mb-8 text-center">
                <h2 className="mb-3 text-3xl font-bold text-gray-900 dark:text-gray-100">
                  Ready to Roll?
                </h2>
                <p className="mx-auto max-w-2xl text-lg text-gray-700 dark:text-gray-400">
                  Roll dice to score points. First to 1,000 points, or highest
                  score wins!
                </p>
              </div>

              <div className="mb-10 flex flex-col sm:flex-row sm:gap-6">
                <button
                  type="button"
                  className="group cursor-pointer relative flex-1 overflow-hidden rounded-xl bg-gradient-to-br from-[#0000FF] to-blue-700 px-8 py-6 text-lg font-semibold text-white transition-all duration-300 ease-out  hover:from-blue-700 hover:to-[#0000FF]"
                  onClick={() => console.log("Host Game clicked")}
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-white/0 to-white/10 opacity-0 transition-opacity duration-300 group-hover:opacity-100"></div>
                  <span className="relative flex items-center justify-center gap-3">
                    <span className="text-2xl">🎲</span>
                    Play Now
                  </span>
                </button>
              </div>
              {/* Winners / Social proof block */}
              <div className="mt-6">
                <FinishedGamesList />
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="flex flex-col space-y-3">
          <Skeleton className="h-[125px] w-[250px] rounded-xl" />
          <div className="space-y-2">
            <Skeleton className="h-4 w-[250px]" />
            <Skeleton className="h-4 w-[200px]" />
          </div>
          <div className="space-y-2">
            <Skeleton className="h-4 w-[250px]" />
            <Skeleton className="h-4 w-[200px]" />
          </div>
          <div className="space-y-2">
            <Skeleton className="h-4 w-[250px]" />
            <Skeleton className="h-4 w-[200px]" />
          </div>
        </div>
      )}
      {showRules && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowRules(false)}
          />
          <div className="relative z-10 mx-4 max-w-3xl rounded-lg bg-white p-6 shadow-xl dark:bg-gray-900">
            <div className="flex justify-end">
              <button
                className="rounded-md cursor-pointer p-2 text-gray-600 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800"
                onClick={() => setShowRules(false)}
                aria-label="Close rules"
              >
                ✕
              </button>
            </div>
            <div className="max-h-[85vh] overflow-auto px-2 pb-4">
              <RulesModal />
            </div>
          </div>
        </div>
      )}
    </div>
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
