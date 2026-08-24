import { query, logError } from '../config/db.js';
import type { User, CreateUser, Account } from '../types/users.d.ts';

export async function findUserById(id: string) {
    try {
        const user = await query({
            text: `SELECT * FROM users WHERE user_id = $1::uuid`,
            values: [id]
        });

        if (user.rows.length == 0) {
            throw new Error("User with specified id not found");
        }

        const userRole = await query({
            text: `
                SELECT r.name
                FROM roles AS r
                JOIN user_roles AS ur ON ur.role_id = r.role_id
                JOIN users AS u ON u.user_id = ur.user_id
                WHERE u.user_id = $1::uuid
            `,
            values: [id]
        });

        const userProfile: Account = {
            id: id,
            email: user.rows[0].email,
            passwordHash: user.rows[0].password_hash,
            firstName: user.rows[0].first_name,
            lastName: user.rows[0].last_name,
            role: userRole.rows.length == 0 ? "" : userRole.rows[0].name
        };

        return userProfile;
    } catch (error: unknown) {
        logError({
            type: "database query",
            func: "findUserById",
            args: [id],
            error: (error instanceof Error) ? error.message : "Unknown error"
        });
        throw error;
    }
}

export async function findUserByEmail(email: string) {
    try {
        const user = await query({
            text: `SELECT * FROM users WHERE email = $1::varchar`,
            values: [email]
        });

        if (user.rows.length == 0) {
            throw new Error("User with specified email not found");
        }

        const userRole = await query({
            text: `
                SELECT r.name
                FROM roles AS r
                JOIN user_roles AS ur ON ur.role_id = r.role_id
                JOIN users AS u ON u.user_id = ur.user_id
                WHERE u.email = $1::varchar
            `,
            values: [email]
        });

        const userProfile: Account = {
            id: user.rows[0].user_id,
            email: email,
            passwordHash: user.rows[0].password_hash,
            firstName: user.rows[0].first_name,
            lastName: user.rows[0].last_name,
            role: userRole.rows.length == 0 ? "" : userRole.rows[0].name
        };

        return userProfile;
    } catch (error: unknown) {
        logError({
            type: "database query",
            func: "findUserById",
            args: [email],
            error: error instanceof Error ? error.message : "Unknown error"
        });
        throw error;
    }
}

export async function createUser({
    email,
    passwordHash,
    firstName,
    lastName
}: CreateUser) {
    try {
        const adminQuery = `
            SELECT u.user_id
            FROM users AS u
            JOIN user_roles AS ur ON u.user_id = ur.user_id
            JOIN roles AS r ON ur.role_id = r.role_id
            WHERE r.name = 'admin'
        `;

        const admins = await query({
            text: adminQuery,
            values: []
        });

        let role = null;

        if (admins.rows.length == 0) {
            role = "admin";
        } else {
            role = "employee";
        }

        const newUserId = await query({ 
            text: `SELECT create_user($1::varchar, $2::varchar, $3::varchar, $4::varchar, $5::varchar) AS user_id`,
            values: [email, passwordHash, firstName, lastName, role] 
        });

        if (newUserId.rows.length == 0) {
            console.log("User creation failed");
            return null;
        }

        const userProfile: User = {
            id: newUserId.rows[0].user_id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role
        };

        return userProfile;
    } catch (error: unknown) {
        logError({
            type: "database query",
            func: "createUser",
            args: [email, passwordHash, firstName, lastName],
            error: (error instanceof Error) ? error.message : "Unknown error"
        })
        throw error;
    }
}

export async function setUserRole({
    email,
    role
}: {
    email: string,
    role: string
}) {
    try {
        const user = await query({
            text: `SELECT user_id FROM users WHERE email = $1::varchar`,
            values: [email]
        });

        if (user.rows.length == 0) {
            throw new Error("User not found");
        }

        void query({
            text: `CALL set_user_role($1::uuid, $2::varchar)`,
            values: [user.rows[0].user_id, role]
        });
    } catch (error: unknown) {
        logError({
            type: "database query",
            func: "setUserRole",
            args: [email, role],
            error: error instanceof Error ? error.message : "Unknown error"
        });

        throw error;
    }
}
