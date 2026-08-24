import express from "express";
import { signUpUser, logInUser, updateUserRole } from "../controllers/users.controller.js"

const router = express();

router.post("/api/users/signup", signUpUser);
router.post("/api/users/login", logInUser);
router.post("/api/users/set-role", updateUserRole);

export { router as usersRouter };
