import { createClient, Errors } from "@farcaster/quick-auth";
import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { db } from "./db";
import { usersTable } from "./db/schema";
import { eq } from "drizzle-orm";

const client = createClient();
export const quickAuthMiddleware = createMiddleware<{
  Variables: {
    user: {
      fid: number;
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
        primaryAddress: dbUser.primaryAddress!,
      });
    } else {
      const user = await resolveUser(payload.sub);
      await db.insert(usersTable).values({
        fid: user.fid,
        primaryAddress: user.primaryAddress,
      });
      c.set("user", user);
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

type FarcasterPrimaryAddressAPIResponse = {
  result: {
    address: {
      fid: number;
      protocol: "ethereum" | "solana";
      address: string;
    };
  };
};

async function resolveUser(fid: number) {
  const primaryAddress = await (async () => {
    const res = await fetch(
      `https://api.farcaster.xyz/fc/primary-address?fid=${fid}&protocol=ethereum`
    );
    if (res.ok) {
      const { result } =
        (await res.json()) as FarcasterPrimaryAddressAPIResponse;
      return result.address.address;
    }
  })();

  return {
    fid,
    primaryAddress,
  };
}
