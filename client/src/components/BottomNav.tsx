import { Link, useLocation } from "@tanstack/react-router";

export default function BottomNav() {
  const location = useLocation();
  const pathname = location.pathname;

  const links = [
    { href: "/", label: "HOME" },
    { href: "/play", label: "GAME" },
    { href: "/leaderboard", label: "BOARD" },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-background border-t-2 border-foreground z-50">
      <div className="flex justify-around items-center h-16">
        {links.map((link) => {
          const isActive = pathname === link.href;
          return (
            <Link
              key={link.href}
              to={link.href}
              className={`flex-1 h-full flex items-center justify-center font-mono text-sm tracking-wider transition-colors ${
                isActive
                  ? "bg-foreground text-background"
                  : "text-foreground hover:bg-foreground/10"
              }`}
            >
              {link.label}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
