import { createRootRoute, Outlet } from "@tanstack/react-router";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import BottomNav from "client/src/components/BottomNav";
import { WagmiProvider, createConfig, http } from "wagmi";
import { base, baseSepolia } from "wagmi/chains";
import { farcasterMiniApp } from "@farcaster/miniapp-wagmi-connector";

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
    <>
      <WagmiProvider config={config}>
        <QueryClientProvider client={queryClient}>
          <Outlet />
          <BottomNav />
        </QueryClientProvider>
      </WagmiProvider>
    </>
  ),
});
