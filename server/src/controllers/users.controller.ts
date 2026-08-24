import { createUser, findUserByEmail, setUserRole } from '../repositories/users.repository.js';
import { logError } from '../config/db.js';
import type { Request, Response } from 'express';
import argon2 from 'argon2';

export async function signUpUser(req: Request, res: Response) {
    try {
        const hash = await hashPassword(req.body.password);

        const user = await createUser({
            email: req.body.email,
            passwordHash: hash,
            firstName: req.body.firstName,
            lastName: req.body.lastName
        });

        if (user == null) {
            return res.status(500).json({
                success: false,
                message: "Internal server error"
            });
        }

        req.session.user = {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role
        };

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

export async function logInUser(req: Request, res: Response) {
    try {
        const user = await findUserByEmail(req.body.email);

        if (!verifyPassword(req.body.password, user.passwordHash)) {
            console.log("Passwords do not match");
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }

        req.session.regenerate((err) => {
            if (err) {
                return res.status(500).json({
                    success: false,
                    message: "Internal server error"
                });
            }

            req.session.user = {
                id: user.id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                role: user.role
            };

            req.session.loggedIn = true;

            return res.status(200).json({
                success: true,
                redirectTo: "/dashboard"
            });
        });

        return;
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

export async function updateUserRole(req: Request, res: Response) {
    const isAdmin = req.session 
                    && req.session.user 
                    && req.session.user.role == "admin";

    if (!isAdmin) {
        return res.status(401).json({
            success: false,
            message: "Unauthorized to update user role"
        });
    }

    try {
        const data = { email: req.body.email, role: req.body.role };
        if (data.email == null || data.role == null) {
            return res.status(400).json({
                success: false,
                message: "User ID or role is null"
            });
        }
        
        void setUserRole(data);

        return res.status(200).json({
            success: true,
            message: "User role updated successfully"
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

async function hashPassword(password: string) {
    try {
        const hash = await argon2.hash(password);
        return hash;
    } catch (error) {
        logError({
            type: "authentication",
            func: "hashPassword",
            args: [], // Don't store plaintext password
            error: error instanceof Error ? error.message : "Unknown error"
        })
        throw error;
    }
}

async function verifyPassword(password: string, hash: string) {
    try {
        const match = await argon2.verify(hash, password);
        if (!match) {
            return false;
        }
        return true;
    } catch (error: unknown) {
        logError({
            type: "authentication",
            func: "verifyPassword",
            args: [], // Don't store plaintext password
            error: error instanceof Error ? error.message : "Unknown error"

        })
        throw error;
    }
}
