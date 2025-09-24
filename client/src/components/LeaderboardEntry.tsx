import { Avatar, AvatarImage, AvatarFallback } from "./ui/avatar";
import { sdk } from "@farcaster/miniapp-sdk";
import { truncateEthAddress } from "@/lib/utils";

type LeaderboardEntryProps = {
  position: number;
  fid: number;
  username: string;
  pfpUrl: string;
  address: `0x${string}`;
  gamesWon: number;
};

function colors(position: number) {
  switch (position) {
    case 1:
      return "bg-yellow-500/80";
    case 2:
      return "bg-slate-400/50";
    case 3:
      return "bg-orange-900/70";
    default:
      return "bg-[#eef0f3]/80";
  }
}

export function LeaderboardEntry({
  position,
  fid,
  username,
  pfpUrl,
  address,
  gamesWon,
}: LeaderboardEntryProps) {
  return (
    <div
      className={`${colors(position)} grid grid-cols-2 border border-neutral-700 rounded-sm w-auto h-16 p-2`}
    >
      <div
        className="cursor-pointer inline-flex justify-start items-center gap-2"
        onClick={async () => {
          await sdk.actions.viewProfile({ fid });
        }}
      >
        <span>{position}</span>
        <Avatar className="border border-neutral-500">
          <AvatarImage src={pfpUrl} alt={username} />
          <AvatarFallback>{username?.charAt(0)}</AvatarFallback>
        </Avatar>
        <div>
          <p className="text-black text-md">{`@${username}`}</p>
          <p className="text-black text-md">{truncateEthAddress(address)}</p>
        </div>
      </div>
      <div className="inline-flex justify-around items-center">
        <p className="text-2xl">{gamesWon}</p>
      </div>
    </div>
  );
}
