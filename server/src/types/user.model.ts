import { users } from '../db/schema.js';
import type { ParamsDictionary } from 'express-serve-static-core';

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type PublicUser = Omit<User, 'passwordHash' | 'createdAt' | 'updatedAt'>;

export type InsertableUser = Omit<
  User,
  'id' | 'password' | 'firstName' | 'lastName' | 'createdAt' | 'updatedAt'
> & {
  passwordHash: string;
};

export type UpdatableUser = {
  email?: string;
  passwordHash?: string;
  firstName?: string;
  lastName?: string;
};

export interface UserParams extends ParamsDictionary {
  id: string;
}
