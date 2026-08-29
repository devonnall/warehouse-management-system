import UsersRepository from "../repositories/users.repository.js";
import type { Request, Response } from 'express';
import type { 
  User,
  PublicUser
} from "../types/users.js";
import argon2 from 'argon2';
import { omit } from "../utils.js";

const usersRepository = new UsersRepository();

export default class UsersController {
  private async hashPassword(password: string): Promise<string> {
    const hash = await argon2.hash(password);
    return hash;
  }

  private async verifyPassword(password: string, hash: string): Promise<boolean> {
    const match = await argon2.verify(hash, password);
    if (!match) {
      return false;
    }
    return true;
  }

  async signUpUser(req: Request, res: Response): Promise<Response> {
    try {
      const hash = await this.hashPassword(req.body.password);

      const newUser: User | null = await usersRepository.create({
        email: req.body.email,
        passwordHash: hash,
        firstName: req.body.firstName,
        lastName: req.body.lastName
      });

      if (newUser == null) {
        return res.status(500).json({
          success: false,
          message: "Internal server error"
        });
      }

      const publicUser: PublicUser = omit(newUser, ["passwordHash", "id"]);

      req.session.user = publicUser;
      req.session.loggedIn = true;

      return res.status(201).json({
        success: true,
        redirectTo: "/dashboard"
      });
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.log(error.message);
      }

      return res.status(500).json({
        success: false,
        message: "Internal server error"
      });
    }
  }

  private regenerateSession(req: Request): Promise<void> {
    return new Promise((resolve, reject) => {
      req.session.regenerate((err) => {
        if (err) return reject(err);
        resolve();
      })
    })
  }

  async logInUser(req: Request, res: Response): Promise<Response> {
    try {
      const user: User | null = await usersRepository.findByEmail(req.body.email);

      if (user == null) {
        return res.status(401).json({
          success: false,
          message: "Invalid email or password"
        });
      }

      if (!this.verifyPassword(req.body.password, user.passwordHash)) {
        return res.status(401).json({
          success: false,
          message: "Invalid email or password"
        });
      }

      await this.regenerateSession(req);

      const publicUser: PublicUser = omit(user, ["passwordHash", "id"]);

      req.session.user = publicUser;
      req.session.loggedIn = true;

      return res.status(200).json({
        success: true,
        message: "Logged in successfully"
      });
    } catch (error: unknown) { 
      if (error instanceof Error) {
        console.log(error.message);
      }

      return res.status(500).json({
        success: false,
        message: "Internal server error"
      });
    }
  }
}
