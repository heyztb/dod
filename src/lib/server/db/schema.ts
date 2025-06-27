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

export const game = sqliteTable('games', {
    id: text('id', { length: 36 })
        .primaryKey()
        .$defaultFn(() => crypto.randomUUID()),
    room: text('room').notNull(),
    seed: text('seed').notNull(),
    commit: text('commit').notNull(),
    current_hash: text('current_hash').notNull(),
    createdAt: integer('created_at', { mode: 'timestamp' })
        .notNull()
        .default(sql`CURRENT_TIMESTAMP`),
    updatedAt: integer('updated_at', { mode: 'timestamp' })
        .notNull()
        .default(sql`CURRENT_TIMESTAMP`)
});
export type Game = InferSelectModel<typeof game>;

export const player = sqliteTable('players', {
    id: text('id').primaryKey(),
    user_id: text('user_id')
        .notNull()
        .references(() => user.id),
    game_id: text('game_id')
        .notNull()
        .references(() => game.id),
    createdAt: integer('created_at', { mode: 'timestamp' })
        .notNull()
        .default(sql`CURRENT_TIMESTAMP`),
    updatedAt: integer('updated_at', { mode: 'timestamp' })
        .notNull()
        .default(sql`CURRENT_TIMESTAMP`)
});
