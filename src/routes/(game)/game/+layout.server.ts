import { redirect } from '@sveltejs/kit';

export async function load({ locals }) {
	const { session, user } = locals;
	if (!session) {
		console.log('No session');
		return redirect(302, '/');
	}
	return { session, user };
}
