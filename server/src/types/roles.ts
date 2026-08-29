import { roles } from "../db/schema.js";

export type Role = typeof roles.$inferSelect;
export type NewRole = typeof roles.$inferInsert;
