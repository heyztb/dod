import { hc } from "hono/client";

export type AppType = typeof import("./index").default;
export type Client = ReturnType<typeof hc<AppType>>;

export const hcWithType = (...args: Parameters<typeof hc>): Client =>
  hc<AppType>(...args);
