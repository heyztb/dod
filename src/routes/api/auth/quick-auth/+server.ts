import { json } from '@sveltejs/kit';
import { createClient } from '@farcaster/quick-auth';
import { getUser, insertUserIfNotExists } from '$lib/server/db/index.js';
import { createSession } from '$lib/server/auth/index.js';
import { getDomainFromUrl } from '$lib';
import { getLogger } from '@logtape/logtape';

const logger = getLogger(['backend', 'auth', 'quick-auth']);

export async function POST({ request, cookies }) {
  try {
    const { token } = await request.json();

    if (!token) {
      return json({ error: 'Missing token' }, { status: 400 });
    }

    // Verify the JWT token with Farcaster Quick Auth
    const client = createClient();
    const domain = getDomainFromUrl(request.url);

    logger.debug('Verifying Quick Auth token', { domain });

    const payload = await client.verifyJwt({
      token,
      domain
    });

    logger.debug('Quick auth verification successful', {
      fid: payload.sub,
      address: payload.address
    });

    const fid = payload.sub as unknown as number;

    // Use existing user management system
    let user = await getUser(fid);
    if (!user) {
      user = await insertUserIfNotExists(fid);
    }
    if (!user) {
      return json({ error: 'Failed to create user' }, { status: 500 });
    }

    // Use existing session system
    const session = await createSession(user.id);
    cookies.set('dod.ztb.dev-session-token', session.token, {
      path: '/',
      httpOnly: true,
      secure: true,
      sameSite: 'none',
      expires: session.expiresAt
    });

    logger.info('Quick auth login successful', { fid, userId: user.id });
    return json({
      success: true,
      user: { fid, id: user.id }
    });

  } catch (error) {
    logger.error('Quick auth verification failed', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined
    });
    return json({
      error: error instanceof Error ? error.message : 'Authentication failed'
    }, { status: 401 });
  }
} 