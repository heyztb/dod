import { createRootRoute, Outlet } from "@tanstack/react-router";
import BottomNav from "client/src/components/BottomNav";
import { WagmiProvider, createConfig, http } from "wagmi";
import { base, baseSepolia } from "wagmi/chains";
import { farcasterMiniApp } from "@farcaster/miniapp-wagmi-connector";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { OnchainKitProvider } from "@coinbase/onchainkit";
import { sdk } from "@farcaster/miniapp-sdk";
import UserDrawer from "@/components/UserDrawer";
import { Toaster } from "sonner";

const config = createConfig({
  chains: [base, baseSepolia],
  transports: {
    [base.id]: http(),
    [baseSepolia.id]: http(),
  },
  connectors: [farcasterMiniApp()],
});

const queryClient = new QueryClient();
const context = await sdk.context;

export const Route = createRootRoute({
  component: () => (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <OnchainKitProvider
          chain={base}
          apiKey={import.meta.env.VITE_ONCHAINKIT_APIKEY}
          projectId={import.meta.env.VITE_CDP_PROJECT_ID}
          config={{
            appearance: {
              name: "Dice of Destiny",
              logo: "https://dod.ztb.dev/favicon.png",
              theme: "hacker",
              mode: "light",
            },
            paymaster:
              "https://api.developer.coinbase.com/rpc/v1/base/I0kkTEekpDpiWfGXgMkAToLmdQXbkiAt",
          }}
          miniKit={{
            enabled: true,
          }}
        >
          {/* Add bottom padding equal to BottomNav height so content (footer) is not covered */}
          <div className="pb-16">
            <header className="p-4 flex justify-between items-center">
              <div className="text-sm font-mono tracking-wider">FARKLE</div>
              <UserDrawer context={context} />
            </header>
            <Outlet />
            <Toaster position={"top-center"} duration={1250} />
            <footer
              className="p-4 text-center hover:underline hover:cursor-pointer"
              onClick={() => {
                sdk.actions.viewProfile({
                  fid: 979284,
                });
              }}
            >
              <p className="text-xs text-muted-foreground font-mono">
                © 2025 HEYZTB.ETH
              </p>
            </footer>
          </div>
          <BottomNav />
        </OnchainKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  ),
});
