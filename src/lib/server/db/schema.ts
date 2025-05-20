import { sql, type InferSelectModel } from 'drizzle-orm';
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

export const user = sqliteTable('users', {
	id: text('id', { length: 36 })
		.primaryKey()
		.$defaultFn(() => crypto.randomUUID()),
	fid: integer('fid').notNull().unique(),
	addedFrame: integer('added_frame').notNull().default(0),
	notificationDetails: text('notification_details', { mode: 'json' }).default(null),
	createdAt: integer('created_at', { mode: 'timestamp' })
		.notNull()
		.default(sql`CURRENT_TIMESTAMP`),
	updatedAt: integer('updated_at', { mode: 'timestamp' })
		.notNull()
		.default(sql`CURRENT_TIMESTAMP`)
});
export type User = InferSelectModel<typeof user>;

export const session = sqliteTable('sessions', {
	id: text('id').primaryKey(),
	token: text('token').notNull().unique(),
	userId: text('user_id')
		.notNull()
		.references(() => user.id),
	createdAt: integer('created_at', { mode: 'timestamp' })
		.notNull()
		.default(sql`CURRENT_TIMESTAMP`),
	updatedAt: integer('updated_at', { mode: 'timestamp' })
		.notNull()
		.default(sql`CURRENT_TIMESTAMP`),
	expiresAt: integer('expires_at', { mode: 'timestamp' }).notNull()
});
export type Session = InferSelectModel<typeof session>;
