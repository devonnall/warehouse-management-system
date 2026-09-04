import type { Request, Response } from 'express';
import { Problem } from '../types/result.model.js';
import type { Result } from '../types/result.model.js';
import type { User, PublicUser, UserParams } from '../types/user.model.js';
import { UserService } from '../services/user.service.js';
import { omit } from '../utils.js';

class UserController {
  constructor(private userService: UserService) {}

  getUserById = async (
    req: Request<UserParams>,
    res: Response
  ): Promise<Response> => {
    try {
      const userResult: Result<User> = await this.userService.getUserById(
        req.params.id
      );

      if (!userResult.ok) {
        return res
          .status(404)
          .json(Problem.notFound('/api/users/:id', req.params.id));
      }

      const publicUser: PublicUser = omit(userResult.value, [
        'passwordHash',
        'createdAt',
        'updatedAt',
      ]);

      return res.status(200).json(publicUser);
    } catch (error: unknown) {
      return res.status(500).json(Problem.internalError());
    }
  };

  // createUser = async (req: Request, res: Response): Promise<Response> => {
  //   try {
  //     if (!req.body.email || !req.body.password) {
  //       return res
  //         .status(Problem.badRequest().status)
  //         .json(Problem.badRequest());
  //     }

  //     const newUser: Result<User> = await this.userService.createUser(
  //       req.body.email,
  //       req.body.password
  //     );

  //     if (!newUser.ok) {
  //       return res
  //         .status(Problem.emailTaken().status)
  //         .json(Problem.emailTaken());
  //     }

  //     const publicUser: PublicUser = omit(newUser.value, [
  //       'passwordHash',
  //       'createdAt',
  //       'updatedAt',
  //     ]);

  //     return res.status(201).json(publicUser);
  //   } catch (error: unknown) {
  //     return res.status(500).json(Problem.internalError());
  //   }
  // };

  updateUser = async (req: Request, res: Response): Promise<Response> => {
    try {
      if (!req.body.userId || !req.body.updateDetails) {
        return res
          .status(Problem.badRequest().status)
          .json(Problem.badRequest());
      }

      const updatedUser: Result<User> = await this.userService.updateUser(
        req.body.userId,
        req.body.userDetails
      );

      if (!updatedUser.ok) {
        return res
          .status(Problem.emailTaken().status)
          .json(Problem.emailTaken());
      }

      const publicUser: PublicUser = omit(updatedUser.value, [
        'passwordHash',
        'createdAt',
        'updatedAt',
      ]);

      return res.status(200).json(publicUser);
    } catch (error: unknown) {
      return res.status(500).json(Problem.internalError());
    }
  };

  deleteUser = async (
    req: Request<UserParams>,
    res: Response
  ): Promise<Response> => {
    try {
      const deleteResult: Result<string> = await this.userService.deleteUser(
        req.params.id
      );

      if (!deleteResult.ok) {
        return res
          .status(404)
          .json(Problem.notFound('/api/users/:id', req.params.id));
      }

      return res.status(200).json({ deletedId: deleteResult.value });
    } catch (error: unknown) {
      return res.status(500).json(Problem.internalError());
    }
  };
}

export { UserController };
