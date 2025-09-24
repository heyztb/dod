import "dotenv/config";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { trimTrailingSlash } from "hono/trailing-slash";
import { quickAuthMiddleware } from "./quickAuthMiddleware";

export const app = new Hono()
  .use(cors())
  .use(logger())
  .use(trimTrailingSlash())
  .basePath("/api")
  .get("/me", quickAuthMiddleware, (c) => {
    return c.json(c.get("user"));
  });

export default app;
