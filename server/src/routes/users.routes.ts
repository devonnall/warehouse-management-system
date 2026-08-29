import express from "express";
import UsersController from "../controllers/users.controller.js"

const router = express();

const usersController = new UsersController();

router.post("/api/users/signup", usersController.signUpUser.bind(usersController));
router.post("/api/users/login", usersController.logInUser.bind(usersController));

export { router as usersRouter };
