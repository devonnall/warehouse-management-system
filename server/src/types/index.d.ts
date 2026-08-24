import "express-session";
import type { User } from "./users.d.js";

declare module "express-session" {
    interface SessionData {
        user: User,
        loggedIn: bool
    }
}
