import { createRootRoute, Outlet } from "@tanstack/react-router";
import BottomNav from "client/src/components/BottomNav";
import { WagmiProvider, createConfig, http } from "wagmi";
import { base, baseSepolia } from "wagmi/chains";
import { farcasterMiniApp } from "@farcaster/miniapp-wagmi-connector";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { OnchainKitProvider } from "@coinbase/onchainkit";
import { HelmetProvider } from "@dr.pogodin/react-helmet";

const config = createConfig({
  chains: [base, baseSepolia],
  transports: {
    [base.id]: http(),
    [baseSepolia.id]: http(),
  },
  connectors: [farcasterMiniApp()],
});

const queryClient = new QueryClient();

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
          <HelmetProvider>
            <Outlet />
          </HelmetProvider>
          <BottomNav />
        </OnchainKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  ),
});
