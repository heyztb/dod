import { json } from '@sveltejs/kit';
import { createClient } from '@farcaster/quick-auth';
import { getUser, insertUserIfNotExists } from '$lib/server/db/index.js';
import { createSession } from '$lib/server/auth/index.js';
import { getDomainFromUrl } from '$lib';

export async function POST({ request, cookies }) {
  try {
    const { token } = await request.json();

    if (!token) {
      return json({ error: 'Missing token' }, { status: 400 });
    }

    // Verify the JWT token with Farcaster Quick Auth
    const client = createClient();
    const domain = getDomainFromUrl(request.url);

    console.log('Verifying Quick Auth token for domain:', domain);

    const payload = await client.verifyJwt({
      token,
      domain
    });

    console.log('Quick auth verification successful:', {
      fid: payload.sub,
      address: payload.address
    });

    const fid = payload.sub as number;

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

    console.log('Quick auth login successful for FID:', fid);
    return json({
      success: true,
      user: { fid, id: user.id }
    });

  } catch (error) {
    console.error('Quick auth verification failed:', error);
    return json({
      error: error instanceof Error ? error.message : 'Authentication failed'
    }, { status: 401 });
  }
} 