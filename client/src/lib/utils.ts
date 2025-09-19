import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// to be used when dealing with amounts of erc20 tokens, which are not usually represented in
// any denomination larger than the base unit and instead we just say 1k, 100k, 1m, etc.
const ALPHABET = ["K", "M", "B", "T"];
const THRESHOLD = 1e3;
export function humanizeNumber(n: number) {
  let idx = 0;
  while (n >= THRESHOLD && ++idx <= ALPHABET.length) n /= THRESHOLD;
  return String(idx === 0 ? n : n + ALPHABET[idx - 1]);
}

const truncateRegex = /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;

export function truncateEthAddress(address: string) {
  const match = address.match(truncateRegex);
  if (!match) return address;
  return match[1] + "\u2026" + match[2];
}
