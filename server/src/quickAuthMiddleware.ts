import { createClient, Errors } from "@farcaster/quick-auth";
import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { db } from "./db";
import { usersTable } from "./db/schema";
import { eq } from "drizzle-orm";
import { type NeynarUserData } from "shared/src/types";

const client = createClient();
export const quickAuthMiddleware = createMiddleware<{
  Variables: {
    user: {
      fid: number;
      username: string;
      pfpUrl: string;
      primaryAddress?: string;
    };
  };
}>(async (c, next) => {
  const authorization = c.req.header("Authorization");
  if (!authorization || !authorization.startsWith("Bearer ")) {
    throw new HTTPException(401, { message: "Missing token" });
  }

  try {
    const payload = await client.verifyJwt({
      token: authorization.split(" ")[1] as string,
      domain: "dod.ztb.dev",
    });

    const dbUser = await db.query.usersTable.findFirst({
      where: eq(usersTable.fid, payload.sub),
    });

    if (dbUser) {
      c.set("user", {
        fid: dbUser.fid,
        username: dbUser.username!,
        pfpUrl: dbUser.pfpUrl!,
        primaryAddress: dbUser.primaryAddress!,
      });
    } else {
      const user = await resolveUser(payload.sub);
      await db.insert(usersTable).values({
        fid: user.fid,
        username: user.username,
        pfpUrl: user.pfp_url,
        primaryAddress: user.verified_addresses.primary.eth_address,
      });
      c.set("user", {
        fid: user.fid,
        username: user.username,
        pfpUrl: user.pfp_url,
        primaryAddress: user.verified_addresses.primary.eth_address,
      });
    }
  } catch (e) {
    if (e instanceof Errors.InvalidTokenError) {
      console.info("Invalid token:", e.message);
      throw new HTTPException(401, { message: "Invalid token" });
    }

    throw e;
  }

  await next();
});

async function resolveUser(fid: number) {
  const userData = await (async () => {
    const res = await fetch(
      `https://api.neynar.com/v2/farcaster/user/bulk/?fids=${fid}`,
      {
        headers: {
          "x-api-key": process.env.NEYNAR_API_KEY!,
          "x-neynar-experimental": "false",
        },
      }
    );
    if (res.ok) {
      const { users } = (await res.json()) as NeynarUserData;
      return users[0];
    }
  })();

  if (!userData) {
    throw new HTTPException(404, { message: "User not found" });
  }

  return userData;
}
