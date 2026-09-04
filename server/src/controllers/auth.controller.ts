import type { NextFunction, Request, Response } from 'express';
import { Problem } from '../types/result.model.js';
import { AuthService } from '../services/auth.service.js';
import type { Result } from '../types/result.model.js';
import type { User, PublicUser } from '../types/user.model.js';
import { omit } from '../utils.js';

export class AuthController {
  constructor(private authService: AuthService) {}

  private regenerateSession = async (req: Request): Promise<void> => {
    return new Promise((resolve, reject) => {
      req.session.regenerate((err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  };

  requireAuth = (req: Request, res: Response, next: NextFunction) => {
    if (req.session && req.session.userId) {
      next();
    } else {
      res.status(401).json(Problem.unauthorized());
    }
  };

  signUp = async (req: Request, res: Response): Promise<Response> => {
    try {
      if (!req.body.email || !req.body.password) {
        return res
          .status(Problem.badRequest().status)
          .json(Problem.badRequest());
      }

      const signupResult: Result<User> = await this.authService.signUp(
        req.body.email,
        req.body.password
      );

      if (!signupResult.ok) {
        // Only possible client-side error for now
        return res
          .status(Problem.emailTaken().status)
          .json(Problem.emailTaken());
      }

      const publicUser: PublicUser = omit(signupResult.value, [
        'passwordHash',
        'createdAt',
        'updatedAt',
      ]);

      return res.status(201).json(publicUser);
    } catch (error: unknown) {
      return res
        .status(Problem.internalError().status)
        .json(Problem.internalError());
    }
  };

  signIn = async (req: Request, res: Response): Promise<Response> => {
    try {
      if (!req.body.email || !req.body.password) {
        return res.status(400).json(Problem.badRequest);
      }

      const signinResult: Result<User> = await this.authService.signIn(
        req.body.email,
        req.body.password
      );

      if (!signinResult.ok) {
        switch (signinResult.error.code) {
          case 'INVALID_CREDENTIALS':
            return res
              .status(Problem.invalidCredentials().status)
              .json(Problem.invalidCredentials());
          case 'WRONG_SIGNIN_TYPE':
            return res
              .status(Problem.wrongSigninType().status)
              .json(Problem.wrongSigninType());
          default:
            return res
              .status(Problem.unknownError().status)
              .json(Problem.unknownError());
        }
      }

      await this.regenerateSession(req);

      req.session.userId = signinResult.value.id;

      const publicUser: PublicUser = omit(signinResult.value, [
        'passwordHash',
        'createdAt',
        'updatedAt',
      ]);
      return res.status(200).json(publicUser);
    } catch (error: unknown) {
      return res.status(500).json(Problem.internalError);
    }
  };
}
