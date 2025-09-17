import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { trimTrailingSlash } from "hono/trailing-slash";
import type { ApiResponse } from "shared/dist";

export const app = new Hono()
    .use(cors())
    .use(logger())
    .use(trimTrailingSlash())
    .basePath("/api")
    .get("/", (c) => {
        return c.text("Hello Hono!");
    })
    .get("/hello", async (c) => {
        const data: ApiResponse = {
            message: "Hello BHVR!",
            success: true,
        };
        return c.json(data, { status: 200 });
    });

export default app;
