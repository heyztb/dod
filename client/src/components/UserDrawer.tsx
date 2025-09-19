import { Avatar, AvatarImage, AvatarFallback } from "./ui/avatar";
import { Drawer, DrawerTrigger, DrawerContent } from "./ui/drawer";
import { Context } from "@farcaster/miniapp-sdk";
import { useAccount, useBalance, useReadContracts } from "wagmi";
import { formatUnits, erc20Abi } from "viem";
import { base } from "wagmi/chains";
import { truncateEthAddress } from "@/lib/utils";
import { Copy } from "lucide-react";
import { Skeleton } from "./ui/skeleton";

type UserDrawerProps = {
  context: Context.MiniAppContext | null;
};

export default function UserDrawer({ context }: UserDrawerProps) {
  const account = useAccount();
  const {
    data: ethBalance,
    isError: isEthError,
    error: ethError,
  } = useBalance({
    address: account.address,
    chainId: base.id,
  });
  if (isEthError) {
    console.error("Error fetching ETH balance:", ethError);
  }
  const {
    data: usdcBalance,
    isError: isUsdcError,
    error: usdcError,
  } = useReadContracts({
    allowFailure: false,
    contracts: [
      {
        address: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
        abi: erc20Abi,
        functionName: "balanceOf",
        args: [account.address as `0x${string}`],
        chainId: base.id,
      },
      {
        address: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
        abi: erc20Abi,
        functionName: "decimals",
        chainId: base.id,
      },
      {
        address: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
        abi: erc20Abi,
        functionName: "symbol",
        chainId: base.id,
      },
    ],
  });
  if (isUsdcError) {
    console.error("Error fetching USDC balance:", usdcError);
  }

  const [balance, decimals] = usdcBalance ?? [];
  const eth = formatUnits(ethBalance?.value ?? 0n, 18);
  const usdc = formatUnits(balance ?? 0n, decimals ?? 6);

  return (
    <Drawer>
      <DrawerTrigger>
        <Avatar className="border border-black">
          <AvatarImage
            src={context?.user.pfpUrl}
            alt={context?.user.username}
          />
          <AvatarFallback>
            {context?.user.displayName?.charAt(0)}
          </AvatarFallback>
        </Avatar>
      </DrawerTrigger>
      <DrawerContent>
        <div className="px-3 pt-0 pb-4 overflow-y-auto max-h-[calc(420px-24px)]">
          <div className="flex items-center gap-3 mb-3">
            <span
              data-slot="avatar"
              className="relative flex size-8 shrink-0 h-10 w-10 border border-border/30 rounded-full overflow-hidden shadow-sm"
            >
              <img
                data-slot="avatar-image"
                className="aspect-square size-full object-cover"
                alt={context?.user.displayName ?? "User Avatar"}
                src={context?.user.pfpUrl}
              />
            </span>
            <div className="flex-1">
              <h3 className="text-sm font-medium -mb-0.5 line-clamp-1">
                {`@${context?.user.username}`}
              </h3>
              <div className="flex items-center">
                <span className="text-xs text-muted-foreground">
                  {truncateEthAddress(account.address ?? "")}
                </span>
                <Copy
                  onClick={() =>
                    navigator.clipboard.writeText(account.address ?? "")
                  }
                  className="ml-1 h-3 w-3 cursor-pointer text-[#0a0b0d]/60 hover:text-[#0a0b0d]"
                />
              </div>
            </div>
          </div>
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-2">
              <div className="rounded-lg bg-muted/30 p-2.5 flex flex-col items-center justify-center">
                <img
                  alt="USDC"
                  loading="lazy"
                  width="18"
                  height="18"
                  decoding="async"
                  data-nimg="1"
                  className="mb-1"
                  style={{ color: "transparent" }}
                  src="/Circle_USDC_Logo.svg"
                />
                <span className="text-xs font-mono">
                  {usdcBalance ? (
                    `${usdc.split(".")[0]}.${usdc.split(".")[1].slice(0, 2)}`
                  ) : (
                    <Skeleton className="h-4 w-12" />
                  )}
                </span>
                <span className="text-[10px] text-muted-foreground">USDC</span>
              </div>
              <div className="rounded-lg bg-muted/30 p-2.5 flex flex-col items-center justify-center">
                <img
                  alt="ETH"
                  loading="lazy"
                  width="18"
                  height="18"
                  decoding="async"
                  data-nimg="1"
                  className="rounded-full mb-1"
                  style={{ color: "transparent" }}
                  src="/eth-diamond-black.svg"
                />
                <span className="text-xs font-mono">
                  {ethBalance ? (
                    `${eth.split(".")[0]}.${eth.split(".")[1].slice(0, 4)}`
                  ) : (
                    <Skeleton className="h-4 w-16" />
                  )}
                </span>
                <span className="text-[10px] text-muted-foreground">ETH</span>
              </div>
            </div>
          </div>
        </div>
      </DrawerContent>
    </Drawer>
  );
}
