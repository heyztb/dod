import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import * as schema from './schema';
import { env } from '$env/dynamic/private';
import type { FrameNotificationDetails } from '@farcaster/frame-sdk';
import { eq } from 'drizzle-orm';
import type { User } from './schema';

if (!env.DATABASE_URL) throw new Error('DATABASE_URL is not set');

const client = new Database(env.DATABASE_URL);

export const db = drizzle(client, { schema });

export const getUser = async (fid: number): Promise<User | null> => {
	try {
		const user = await db.select().from(schema.user).where(eq(schema.user.fid, fid)).limit(1).get();
		if (user) {
			return user;
		}
		return null;
	} catch (error) {
		console.error(error);
		return null;
	}
};

export const insertUserIfNotExists = async (fid: number): Promise<User | null> => {
	try {
		const user = await db
			.insert(schema.user)
			.values({ fid })
			.onConflictDoNothing({ target: schema.user.fid })
			.returning()
			.get();
		return user;
	} catch (error) {
		console.error(error);
		return null;
	}
};

export const updateUserNotificationDetails = async (
	fid: number,
	notificationDetails: FrameNotificationDetails
): Promise<void> => {
	try {
		db.update(schema.user).set({ notificationDetails }).where(eq(schema.user.fid, fid)).run();
	} catch (error) {
		console.error(error);
	}
};

export const deleteUserNotificationDetails = async (fid: number): Promise<void> => {
	try {
		await db
			.update(schema.user)
			.set({ notificationDetails: null })
			.where(eq(schema.user.fid, fid))
			.run();
	} catch (error) {
		console.error(error);
	}
};
