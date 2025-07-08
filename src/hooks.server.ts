import { type Handle } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import adze from 'adze';
import { randomUUID } from 'crypto';
import { getDomainFromUrl } from '$lib';
import { createClient } from '@farcaster/quick-auth';
import { getUser } from '$lib/server/db';

const auth = (): Handle => {
	const logger = adze.ns('backend', 'auth');
	return async ({ event, resolve }) => {
		const token = event.cookies.get('dod.ztb.dev-session-token');
		if (token) {
			logger.debug('validating session', {
				requestId: event.locals.requestId,
				path: event.request.url
			});
			// Verify the JWT token with Farcaster Quick Auth
			const client = createClient();
			const domain = getDomainFromUrl(event.request.url);

			logger.debug('Verifying Quick Auth token', { domain });

			const payload = await client.verifyJwt({
				token,
				domain
			});

			logger.debug('Quick auth verification successful', {
				fid: payload.sub
			});

			const fid = parseInt(payload.sub!);
			const user = await getUser(fid);
			event.locals.user = user;
		}
		return resolve(event);
	};
};

const id = (): Handle => {
	return async ({ event, resolve }) => {
		const id = randomUUID();
		event.locals.requestId = id;
		const response = await resolve(event);
		response.headers.set('x-request-id', id);
		return response;
	};
};

export const handle = sequence(id(), auth());
