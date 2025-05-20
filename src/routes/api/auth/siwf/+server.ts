import { json } from '@sveltejs/kit';
import { createAppClient, viemConnector } from '@farcaster/auth-client';
import { getUser, insertUserIfNotExists } from '$lib/server/db/index.js';
import { createSession } from '$lib/server/auth/index.js';
import { getDomainFromUrl } from '$lib';

export async function POST({ request, cookies }) {
	const { signature, message, nonce } = await request.json();
	console.log('cookies', cookies.getAll());
	if (!nonce) {
		return json({ error: 'Missing nonce' }, { status: 401 });
	}
	if (nonce !== cookies.get('dod.ztb.dev-csrf')) {
		return json({ error: 'Mismatch nonce' }, { status: 401 });
	}

	const appClient = createAppClient({
		ethereum: viemConnector()
	});
	const verifyResponse = await appClient.verifySignInMessage({
		message,
		signature,
		nonce,
		domain: getDomainFromUrl(request.url)
	});
	const { success, fid, error } = verifyResponse;
	console.log('verifySignInMessage', { success, fid, error });
	if (error) {
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

	console.log('login', 'done');
	return json({ success: true });
}
