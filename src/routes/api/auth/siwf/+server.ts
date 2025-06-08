import { json } from '@sveltejs/kit';
import { createAppClient, viemConnector } from '@farcaster/auth-client';
import { getUser, insertUserIfNotExists } from '$lib/server/db/index.js';
import { createSession } from '$lib/server/auth/index.js';
import { getDomainFromUrl } from '$lib';
import { env } from '$env/dynamic/private';
import { getLogger } from '@logtape/logtape';

const logger = getLogger(['backend', 'auth', 'siwf']);

export async function POST({ request, cookies }) {
	const { signature, message, nonce } = await request.json();
	logger.debug('SIWF authentication attempt', {
		hasNonce: !!nonce,
		cookieCount: cookies.getAll().length
	});
	if (!nonce) {
		return json({ error: 'Missing nonce' }, { status: 401 });
	}
	if (nonce !== cookies.get('dod.ztb.dev-csrf')) {
		return json({ error: 'Mismatch nonce' }, { status: 401 });
	}

	const appClient = createAppClient({
		ethereum: viemConnector({
			rpcUrl: `https://base-mainnet.g.alchemy.com/v2/${env.ALCHEMY_API_KEY}`
		})
	});
	const verifyResponse = await appClient.verifySignInMessage({
		message,
		signature,
		nonce,
		domain: getDomainFromUrl(request.url),
		acceptAuthAddress: true
	});
	const { success, fid, error } = verifyResponse;
	logger.debug('SIWF message verification result', { success, fid, hasError: !!error });
	if (error) {
		logger.warn('SIWF verification failed', {
			error: error.message,
			fid
		});
		return json({ error: error.message }, { status: 401 });
	}

	let user = await getUser(fid);
	if (!user) {
		user = await insertUserIfNotExists(fid);
	}
	if (!user) {
		return json({ error: 'Something went wrong' }, { status: 401 });
	}
	const session = await createSession(user.id);
	cookies.set('dod.ztb.dev-session-token', session.token, {
		path: '/',
		httpOnly: true,
		secure: true,
		sameSite: 'none',
		expires: session.expiresAt
	});

	logger.info('SIWF login successful', { fid, userId: user.id });
	return json({ success: true });
}
