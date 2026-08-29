import { db } from "../db/index.js";
import { eq, and } from "drizzle-orm";
import {
  organizations,
  organizationUsers,
  users,
  roles,
  userRoles
} from "../db/schema.js";
import type { 
  Organization, 
  NewOrganizationInput,
  NewOrganization,
  OrganizationUser,
  NewOrganizationUser,
  OrganizationUserProfile
} from "../types/organizations.ts";
import type { User } from "../types/users.ts";

export default class OrganizationsRepository {
  async findById(id: string): Promise<Organization | null> {
    const [organization]: Organization[] = await db
      .select()
      .from(organizations)
      .where(eq(organizations.id, id));

    return organization ?? null;
  }

  async findByName(name: string): Promise<Organization | null> {
    const [organization]: Organization[] = await db
      .select()
      .from(organizations)
      .where(eq(organizations.name, name));

    return organization ?? null;
  }

  async findAllUsers(id: string): Promise<OrganizationUserProfile[] | null> {
    const orgUsers: OrganizationUserProfile[] = await db
      .select({
        roleName: roles.name,
        firstName: users.firstName,
        lastName: users.lastName,
        email: users.email,
        joinedAt: organizationUsers.joinedAt,
        isActive: organizationUsers.isActive
      })
      .from(users)
      .innerJoin(organizationUsers,
                eq(organizationUsers.userId, users.id))
      .innerJoin(userRoles, eq(userRoles.userId, users.id))
      .innerJoin(roles, eq(roles.id, userRoles.roleId))
      .where(eq(organizations.id, id));

    return orgUsers ?? null;
  }

  async create(organizationDetails: NewOrganizationInput): Promise<NewOrganization | null> {
    const [newOrganization]: NewOrganization[] = await db
      .insert(organizations)
      .values(organizationDetails)
      .returning();

    return newOrganization ?? null;
  }

  async update(organization: Organization): Promise<Organization | null> {
    const [updatedOrganization]: Organization[] = await db
      .update(organizations)
      .set(organization)
      .where(eq(organizations.id, organization.id))
      .returning();

    return updatedOrganization ?? null;
  }

  async delete(organization: Organization): Promise<string | null> {
    const [deletedOrganization]: Organization[] = await db
      .delete(organizations)
      .where(eq(organizations.id, organization.id))
      .returning();

    return deletedOrganization?.id ?? null;
  }

  async addUser(user: User, organizationId: string): Promise<NewOrganizationUser | null> {
    const [newOrganizationUser]: NewOrganizationUser[] = await db
      .insert(organizationUsers)
      .values({
        organizationId: organizationId,
        userId: user.id
      })
      .returning();

    return newOrganizationUser ?? null;    
  }

  async removeUser(user: User, organizationId: string): Promise<OrganizationUser | null> {
    const [removedUser]: OrganizationUser[] = await db
      .delete(organizationUsers)
      .where(and(
        eq(organizationUsers.userId, user.id),
        eq(organizations.id, organizationId)
      ))
      .returning();

    return removedUser ?? null;
  }
}
