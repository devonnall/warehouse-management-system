import argon2 from 'argon2';
import { UserService } from './user.service.js';
import type { Result } from '../types/result.model.js';
import type { User } from '../types/user.model.js';
import { ok, err } from '../types/result.model.js';

export class AuthService {
  constructor(private userService: UserService) {}

  signUp = async (email: string, password: string): Promise<Result<User>> => {
    const exists: Result<User> = await this.userService.getUserByEmail(email);
    if (exists.ok) {
      return err({
        code: 'EMAIL_TAKEN',
        message: `Account with email ${email} already exists`,
      });
    }

    const hash: string = await argon2.hash(password);
    const result: Result<User> = await this.userService.createUser(email, hash);
    return result;
  };

  signIn = async (email: string, password: string): Promise<Result<User>> => {
    const user: Result<User> = await this.userService.getUserByEmail(email);
    if (!user.ok) {
      return err({
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      });
    }

    if (user.value.passwordHash == null) {
      return err({
        code: 'WRONG_SIGNIN_TYPE',
        message: 'Account does not use email/password signin',
      });
    }

    const match: boolean = await argon2.verify(
      user.value.passwordHash,
      password
    );

    if (!match) {
      return err({
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      });
    }

    return ok(user.value);
  };
}
