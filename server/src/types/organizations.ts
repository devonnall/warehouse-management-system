import { organizations, organizationUsers } from "../db/schema.js";

export type Organization = typeof organizations.$inferSelect;
export type NewOrganization = typeof organizations.$inferInsert;
export type OrganizationUser = typeof organizationUsers.$inferSelect;
export type NewOrganizationUser = typeof organizationUsers.$inferInsert;

export interface OrganizationUserProfile {
  roleName: string,
  firstName: string,
  lastName: string,
  email: string,
  joinedAt: Date,
  isActive: boolean
}

export interface NewOrganizationInput {
  name: string,
  organizationType: string,
  contactEmail: string,
  contactPhone: string,
  billingAddress: string
}
