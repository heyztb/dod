import { createClient, Errors } from "@farcaster/quick-auth"
import { createMiddleware } from "hono/factory"
import { HTTPException } from "hono/http-exception"

const client = createClient()
export const quickAuthMiddleware = createMiddleware<{
  Variables: {
    user: {
      fid: number
      primaryAddress?: string
    }
  }
}>(async (c, next) => {
  const authorization = c.req.header('Authorization')
  if (!authorization || !authorization.startsWith('Bearer ')) {
    throw new HTTPException(401, { message: 'Missing token' })
  }
 
  try {
    const payload = await client.verifyJwt({
      token: authorization.split(' ')[1] as string,
      domain: "dod.ztb.dev",
    })
 
    const user = await resolveUser(payload.sub)
    c.set('user', user)
  } catch (e) {
    if (e instanceof Errors.InvalidTokenError) {
      console.info('Invalid token:', e.message)
      throw new HTTPException(401, { message: 'Invalid token' })
    }
 
    throw e
  }
 
  await next()
})

type FarcasterPrimaryAddressAPIResponse = {
     result: {
         address: { 
            fid: number, 
            protocol: "ethereum" | "solana", 
            address: string 
        } 
    } 
}

// TODO: Update this to use Neynar or my own database
async function resolveUser(fid: number) {
  const primaryAddress = await (async () => {
    const res = await fetch(
      `https://api.farcaster.xyz/fc/primary-address?fid=${fid}&protocol=ethereum`,
    )
    if (res.ok) {
      const { result } = await res.json() as FarcasterPrimaryAddressAPIResponse
      return result.address.address
    }
  })()
 
  return {
    fid,
    primaryAddress,
  }
}