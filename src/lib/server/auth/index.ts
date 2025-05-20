import { encodeBase32LowerCaseNoPadding, encodeHexLowerCase } from '@oslojs/encoding';
import { sha256 } from '@oslojs/crypto/sha2';
import type { User, Session } from '$lib/server/db/schema';
import { db } from '$lib/server/db';
import * as schema from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';

export async function createSession(userId: string): Promise<Session> {
	const bytes = new Uint8Array(32);
	crypto.getRandomValues(bytes);
	const token = encodeBase32LowerCaseNoPadding(bytes);
	const id = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));
	const session: Session = {
		id,
		token,
		userId,
		expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7), // 7 day
		createdAt: new Date(),
		updatedAt: new Date()
	};
	await db.insert(schema.session).values(session);
	return session;
}

export async function validateSession(token: string): Promise<SessionValidationResult> {
	const id = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));
	const result = await db
		.select({ user: schema.user, session: schema.session })
		.from(schema.session)
		.innerJoin(schema.user, eq(schema.session.userId, schema.user.id))
		.where(eq(schema.session.id, id));
	if (result.length < 1) {
		return { user: null, session: null };
	}

	const { session, user } = result[0];
	if (Date.now() >= session.expiresAt.getTime()) {
		await db.delete(schema.session).where(eq(schema.session.id, id));
		return { user: null, session: null };
	}

	if (Date.now() >= session.expiresAt.getTime() - 1000 * 60 * 60 * 24 * 3) {
		session.expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7);
		await db
			.update(schema.session)
			.set({ expiresAt: session.expiresAt })
			.where(eq(schema.session.id, id));
	}

	return { session, user };
}

export async function invalidateSession(sessionId: string) {
	await db.delete(schema.session).where(eq(schema.session.id, sessionId));
}

export async function invalidateAllSessions(userId: string) {
	await db.delete(schema.session).where(eq(schema.session.userId, userId));
}

export type SessionValidationResult =
	| { user: User; session: Session }
	| { user: null; session: null };
