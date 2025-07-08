import { error, json, type RequestEvent } from '@sveltejs/kit';
import { createClient, Errors } from '@farcaster/quick-auth';
import { getUser, insertUserIfNotExists } from '$lib/server/db/index.js';
import { getDomainFromUrl } from '$lib';
import adze from 'adze';

export async function POST({ request, cookies }: RequestEvent) {
	const log = adze.ns('backend', 'auth', 'quick-auth');
	const { token } = await request.json();

	if (!token) {
		return json({ error: 'Missing token' }, { status: 400 });
	}

	// Verify the JWT token with Farcaster Quick Auth
	const client = createClient();
	const domain = getDomainFromUrl(request.url);

	log.debug('Verifying Quick Auth token', { domain });

	try {
		const payload = await client.verifyJwt({
			token,
			domain
		});
		log.debug('Quick auth verification successful', {
			fid: payload.sub
		});

		const fid = payload.sub as unknown as number;

		// Use existing user management system
		let user = await getUser(fid);
		if (!user) {
			log.info('new user', { fid });
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

		log.info('Quick auth login successful', { fid, userId: user.id });
		return json({
			success: true,
			user: { fid, id: user.id }
		});
	} catch (e) {
		if (e instanceof Errors.InvalidTokenError) {
			log.error('invalid token', { error: e });
			error(403, 'invalid token');
		}
	}
}
