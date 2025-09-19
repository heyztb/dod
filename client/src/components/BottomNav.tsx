import { House, Gamepad, ChartNoAxesColumn } from "lucide-react";
import { useState } from "react";
import { linkOptions, Link, useLocation } from "@tanstack/react-router";

export default function BottomNav() {
  const [pressed, setPressed] = useState<
    "home" | "play" | "leaderboard" | null
  >(null);
  const location = useLocation();
  const pathname = location.pathname;
  const isHome = pathname === "/";
  const isPlay = pathname === "/play";
  const isLeaderboard = pathname === "/leaderboard";

  const homeLinkOpts = linkOptions({
    to: "/",
  });
  const playLinkOpts = linkOptions({
    to: "/play",
  });
  const leaderboardLinkOpts = linkOptions({
    to: "/leaderboard",
  });

  return (
    <nav
      aria-label="Bottom navigation"
      className="fixed bottom-0 left-0 right-0 z-40 bg-white/90 backdrop-blur border-t border-gray-300"
    >
      <div className="max-w-xl mx-auto px-0">
        <ul className="grid grid-cols-3 gap-0 h-20">
          <li className="h-full border-r border-gray-300">
            <Link
              {...homeLinkOpts}
              onPointerDown={() => setPressed("home")}
              onPointerUp={() => setPressed(null)}
              onPointerLeave={() => setPressed(null)}
              onPointerCancel={() => setPressed(null)}
              onKeyDown={(e) => {
                if (e.key === " " || e.key === "Enter") setPressed("home");
              }}
              onKeyUp={(e) => {
                if (e.key === " " || e.key === "Enter") setPressed(null);
              }}
              className={`flex items-center justify-center w-full h-full transform transition-transform duration-150 ease-out active:translate-y-1 active:scale-95 ${
                isHome
                  ? "text-[#0000FF] hover:text-[#0000FF]/60"
                  : "text-[#0a0b0d] hover:text-[#0a0b0d]/60"
              } transition-colors duration-200 ${
                pressed === "home" ? "translate-y-1 scale-95 shadow-inner" : ""
              }`}
            >
              <House className="w-10 h-10" />
            </Link>
          </li>
          <li className="h-full border-r border-gray-300">
            <Link
              {...playLinkOpts}
              onPointerDown={() => setPressed("play")}
              onPointerUp={() => setPressed(null)}
              onPointerLeave={() => setPressed(null)}
              onPointerCancel={() => setPressed(null)}
              onKeyDown={(e) => {
                if (e.key === " " || e.key === "Enter") setPressed("play");
              }}
              onKeyUp={(e) => {
                if (e.key === " " || e.key === "Enter") setPressed(null);
              }}
              className={`flex items-center justify-center w-full h-full transform transition-transform duration-150 ease-out active:translate-y-1 active:scale-95 ${
                isPlay
                  ? "text-[#0000FF] hover:text-[#0000FF]/60"
                  : "text-[#0a0b0d] hover:text-[#0a0b0d]/60"
              } transition-colors duration-200 ${
                pressed === "play" ? "translate-y-1 scale-95 shadow-inner" : ""
              }`}
            >
              <Gamepad className="w-10 h-10" />
            </Link>
          </li>
          <li className="h-full">
            <Link
              {...leaderboardLinkOpts}
              onPointerDown={() => setPressed("leaderboard")}
              onPointerUp={() => setPressed(null)}
              onPointerLeave={() => setPressed(null)}
              onPointerCancel={() => setPressed(null)}
              onKeyDown={(e) => {
                if (e.key === " " || e.key === "Enter")
                  setPressed("leaderboard");
              }}
              onKeyUp={(e) => {
                if (e.key === " " || e.key === "Enter") setPressed(null);
              }}
              className={`flex items-center justify-center w-full h-full transform transition-transform duration-150 ease-out active:translate-y-1 active:scale-95 ${
                isLeaderboard
                  ? "text-[#0000FF] hover:text-[#0000FF]/60"
                  : "text-[#0a0b0d] hover:text-[#0a0b0d]/60"
              } transition-colors duration-200 ${
                pressed === "leaderboard"
                  ? "translate-y-1 scale-95 shadow-inner"
                  : ""
              }`}
            >
              <ChartNoAxesColumn className="w-10 h-10" />
            </Link>
          </li>
        </ul>
      </div>
    </nav>
  );
}
