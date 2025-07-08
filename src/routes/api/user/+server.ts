import { json, type RequestEvent } from '@sveltejs/kit';
import { db, insertUserIfNotExists } from '$lib/server/db';
import * as schema from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';

export const POST = async ({ request }: RequestEvent) => {
	const { fid } = await request.json();
	try {
		insertUserIfNotExists(fid);
		return json({ success: true });
	} catch (error) {
		console.error(error);
		return json({ success: false, error: 'Failed to insert user' }, { status: 500 });
	}
};

export const PATCH = async ({ request, locals }: RequestEvent) => {
	const { token, url } = await request.json();

	const { user } = locals;
	if (!user) {
		return json({ error: 'User not found' }, { status: 404 });
	}

	db.update(schema.user)
		.set({
			notificationDetails: JSON.stringify({ token: token, url: url })
		})
		.where(eq(schema.user.id, user.id))
		.run();

	return json({ success: true });
};
