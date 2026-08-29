import { users } from "../db/schema.js";

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type PublicUser = Omit<User, "passwordHash" | "id">;

export interface NewUserInput {
  email: string,
  passwordHash: string,
  firstName: string,
  lastName: string
}
