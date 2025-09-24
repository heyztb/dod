export type Player = {
  id: string;
  name: string;
  farcasterName?: string;
  ens?: string;
  entry: { amount: number; symbol: string };
};

export type FinishedGame = {
  id: string;
  gameId: string;
  players: Player[]; // min 2, max 4
  winnerId: string; // player id
  timestamp: string;
};

const now = Date.now();

const mockFinishedGames: FinishedGame[] = [
  {
    id: "fg-1",
    gameId: "G-110",
    players: [
      {
        id: "p1",
        name: "Ava Thompson",
        farcasterName: "@avat",
        ens: "ava.eth",
        entry: { amount: 5, symbol: "USDC" },
      },
      {
        id: "p2",
        name: "Liam Rivera",
        farcasterName: "@liam",
        ens: "liam.eth",
        entry: { amount: 5, symbol: "USDC" },
      },
    ],
    winnerId: "p1",
    timestamp: new Date(now - 1000 * 60 * 2).toISOString(),
  },
  {
    id: "fg-2",
    gameId: "G-111",
    players: [
      {
        id: "p3",
        name: "Noah Patel",
        farcasterName: "@noahp",
        ens: "noah.eth",
        entry: { amount: 10, symbol: "USDC" },
      },
      {
        id: "p4",
        name: "Sofia Kim",
        farcasterName: "@sofiak",
        ens: "sofia.eth",
        entry: { amount: 10, symbol: "USDC" },
      },
      {
        id: "p5",
        name: "Mason Lee",
        farcasterName: "@masonl",
        ens: "mason.eth",
        entry: { amount: 10, symbol: "USDC" },
      },
    ],
    winnerId: "p5",
    timestamp: new Date(now - 1000 * 60 * 10).toISOString(),
  },
  {
    id: "fg-3",
    gameId: "G-112",
    players: [
      {
        id: "p6",
        name: "Olivia Garcia",
        farcasterName: "@oliviag",
        ens: "olivia.eth",
        entry: { amount: 0.01, symbol: "ETH" },
      },
      {
        id: "p7",
        name: "Ethan Brown",
        farcasterName: "@ethanb",
        ens: "ethan.eth",
        entry: { amount: 0.01, symbol: "ETH" },
      },
      {
        id: "p8",
        name: "Maya Singh",
        farcasterName: "@mayas",
        ens: "maya.eth",
        entry: { amount: 0.01, symbol: "ETH" },
      },
      {
        id: "p9",
        name: "Lucas Wang",
        farcasterName: "@lucasw",
        ens: "lucas.eth",
        entry: { amount: 0.01, symbol: "ETH" },
      },
    ],
    winnerId: "p6",
    timestamp: new Date(now - 1000 * 60 * 30).toISOString(),
  },
];

export default mockFinishedGames;
