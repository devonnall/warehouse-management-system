import { UserRepository } from '../repositories/user.repository.js';
import type { UpdatableUser, User } from '../types/user.model.js';
import type { Result } from '../types/result.model.js';
import { ok, err } from '../types/result.model.js';

class UserService {
  constructor(private userRepository: UserRepository) {}

  getUserById = async (id: string): Promise<Result<User>> => {
    return this.userRepository.findById(id);
  };

  getUserByEmail = async (email: string): Promise<Result<User>> => {
    return this.userRepository.findByEmail(email);
  };

  createUser = async (
    email: string,
    passwordHash: string
  ): Promise<Result<User>> => {
    const existing: Result<User> = await this.userRepository.findByEmail(email);
    if (existing.ok) {
      return err({
        code: 'EMAIL_TAKEN',
        message: `Account with email ${email} already exists`,
      });
    }

    const newUser: Result<User> = await this.userRepository.create({
      email: email,
      passwordHash: passwordHash,
    });

    return newUser;
  };

  updateUser = async (
    userId: string,
    userDetails: UpdatableUser
  ): Promise<Result<User>> => {
    if (userDetails.email) {
      const user: Result<User> = await this.userRepository.findByEmail(
        userDetails.email
      );

      if (user.ok) {
        return err({
          code: 'EMAIL_TAKEN',
          message: 'Email is already in use',
        });
      }
    }

    const updatedUser: Result<User> = await this.userRepository.update(
      userId,
      userDetails
    );

    return updatedUser;
  };

  deleteUser = async (userId: string): Promise<Result<string>> => {
    const user: Result<User> = await this.userRepository.findById(userId);

    if (!user.ok) {
      return err({
        code: 'USER_NOT_FOUND',
        message: `User with ID ${userId} not found`,
      });
    }

    return ok(user.value.id);
  };
}

export { UserService };
