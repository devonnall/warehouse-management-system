import { db } from '../db/index.js';
import { users } from "../db/schema.js";
import { eq } from "drizzle-orm";
import type { 
  User, 
  NewUser,
  NewUserInput,
} from "../types/users.js";

export default class UsersRepository {
  async findById(id: string): Promise<User | null> {
    const [user]: User[] = await db
    .select()
    .from(users)
    .where(eq(users.id, id));

    return user ?? null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const [user]: User[] = await db
    .select()
    .from(users)
    .where(eq(users.email, email));

    return user ?? null;
  }

  async create(user: NewUserInput): Promise<User | null> {
    const [newUser]: User[] = await db
      .insert(users)
      .values(user)
      .returning();

    return newUser ?? null;
  }

  async update(user: User): Promise<User | null> {
    const [updatedUser]: User[] = await db
      .update(users)
      .set(user)
      .where(eq(users.id, user.id))
      .returning();

    return updatedUser ?? null;
  }

  async delete(user: User): Promise<string | null> {
    const [deletedUserEmail]: User[] = await db
      .delete(users)
      .where(eq(users.id, user.id))
      .returning();

    return deletedUserEmail?.email ?? null;
  }
}
