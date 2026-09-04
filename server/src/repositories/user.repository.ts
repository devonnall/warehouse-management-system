import { db } from '../db/index.js';
import { users } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import type {
  User,
  InsertableUser,
  UpdatableUser,
} from '../types/user.model.js';
import type { Result } from '../types/result.model.js';
import { ok, err } from '../types/result.model.js';

export class UserRepository {
  async findById(id: string): Promise<Result<User>> {
    const [user]: User[] = await db
      .select()
      .from(users)
      .where(eq(users.id, id));

    if (user == null) {
      return err({
        code: 'USER_NOT_FOUND',
        message: `User with ID ${id} not found`,
      });
    }

    return ok(user);
  }

  async findByEmail(email: string): Promise<Result<User>> {
    const [user]: User[] = await db
      .select()
      .from(users)
      .where(eq(users.email, email));

    if (user == null) {
      return err({
        code: 'USER_NOT_FOUND',
        message: `User with email ${email} does not exist`,
      });
    }

    return ok(user);
  }

  async create(user: InsertableUser): Promise<Result<User>> {
    const [newUser]: User[] = await db.insert(users).values(user).returning();

    if (newUser == null) {
      return err({
        code: 'CREATE_USER_ERROR',
        message: 'A problem occurred creating the user',
      });
    }

    return ok(newUser);
  }

  async update(
    userId: string,
    updateFields: UpdatableUser
  ): Promise<Result<User>> {
    const [updatedUser]: User[] = await db
      .update(users)
      .set(updateFields)
      .where(eq(users.id, userId))
      .returning();

    if (updatedUser == null) {
      return err({
        code: 'UPDATE_USER_ERROR',
        message: 'A problem occurred updating the user',
      });
    }

    return ok(updatedUser);
  }

  async delete(user: User): Promise<Result<string>> {
    const [deletedUser]: User[] = await db
      .delete(users)
      .where(eq(users.id, user.id))
      .returning();

    if (deletedUser == null) {
      return err({
        code: 'DELETE_USER_ERROR',
        message: 'A problem occurred deleting the user',
      });
    }

    return ok(deletedUser.id);
  }
}
