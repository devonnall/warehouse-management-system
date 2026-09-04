import express from 'express';
import { UserRepository } from '../repositories/user.repository.js';
import { UserService } from '../services/user.service.js';
import { UserController } from '../controllers/user.controller.js';
import { AuthService } from '../services/auth.service.js';
import { AuthController } from '../controllers/auth.controller.js';

const router = express();

const userRepository = new UserRepository();
const userService = new UserService(userRepository);
const userController = new UserController(userService);
const authService = new AuthService(userService);
const authController = new AuthController(authService);

router.get(
  '/api/users/:id',
  authController.requireAuth,
  userController.getUserById
);
router.delete(
  '/api/users/:id',
  authController.requireAuth,
  userController.deleteUser
);
router.put(
  '/api/users/:id',
  authController.requireAuth,
  userController.updateUser
);

export { router as usersRouter };
