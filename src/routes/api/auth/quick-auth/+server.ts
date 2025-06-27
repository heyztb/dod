import { json, type RequestEvent } from '@sveltejs/kit';
import { createClient } from '@farcaster/quick-auth';
import { getUser, insertUserIfNotExists } from '$lib/server/db/index.js';
import { getDomainFromUrl } from '$lib';
import { getLogger } from '@logtape/logtape';

const logger = getLogger(['backend', 'auth', 'quick-auth']);

export async function POST({ request, cookies }: RequestEvent) {
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

        cookies.set('dod.ztb.dev-session-token', token, {
            path: '/',
            httpOnly: true,
            secure: true,
            sameSite: 'none',
            expires: new Date(Date.now() + 1000 * 60 * 60 * 1) // expires in 1 hour
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
        return json(
            {
                error: error instanceof Error ? error.message : 'Authentication failed'
            },
            { status: 401 }
        );
    }
}

