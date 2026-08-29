import { db } from "../db/index.js";
import { eq } from "drizzle-orm";
import {
  roles,
  userRoles
} from "../db/schema.js";
import type { Role, NewRole, NewUserRole } from "../types/roles.ts";

export default class RolesRepository {
  async findById(id: number): Promise<Role | null> {
    const [role]: Role[] = await db
      .select()
      .from(roles)
      .where(eq(roles.id, id));

    return role ?? null;
  }

  async findByName(name: string): Promise<Role | null> {
    const [role]: Role[] = await db
      .select()
      .from(roles)
      .where(eq(roles.name, name));

    return role ?? null;
  }

  async findAll(): Promise<Role[] | null> {
    const allRoles: Role[] = await db.select().from(roles);
    return allRoles ?? null;
  }

  async create(name: string, description: string = "No description"): Promise<NewRole | null> {
    const [newRole]: NewRole[] = await db
      .insert(roles)
      .values({
        name,
        description
      })
      .returning();

    return newRole ?? null;
  }

  async update(role: Role): Promise<Role | null> {
    const [updatedRole]: Role[] = await db
      .update(roles)
      .set(role)
      .where(eq(roles.id, role.id))
      .returning();

    return updatedRole ?? null;
  }

  async delete(role: Role): Promise<number | null> {
    const [deletedRole]: Role[] = await db
      .delete(roles)
      .where(eq(roles.id, role.id))
      .returning();

    return deletedRole?.id ?? null;
  }

  async insertUserRole(userId: string, organizationId: string, roleId: number): Promise<NewUserRole | null> {
    const [newUserRole]: NewUserRole[] = await db
      .insert(userRoles)
      .values({
        userId,
        organizationId,
        roleId
      })
      .onConflictDoNothing()
      .returning();

    return newUserRole ?? null;
  }
}
