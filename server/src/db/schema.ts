import { int, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const usersTable = sqliteTable("users", {
  id: int().primaryKey({ autoIncrement: true }),
  fid: int().notNull().unique(),
  primaryAddress: text().unique(),
  username: text().unique(),
  pfpUrl: text(),
  notificationDetails: text(),
  added: int().notNull().default(0),
});
