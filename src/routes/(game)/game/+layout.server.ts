import { validateSession } from '$lib/server/auth';
import { redirect } from '@sveltejs/kit';

export async function load({ cookies }) {
	const { session, user } = await validateSession(cookies.get('dod.ztb.dev-session-token') ?? '');
	if (!session) {
		console.log('No session');
		return redirect(302, '/');
	}
	return { session, user };
}
