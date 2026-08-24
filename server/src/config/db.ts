import pg from 'pg';
import type { ErrorLog } from '../types/logs.d.ts';

const { Pool } = pg;

export const db = new Pool({
    connectionString: process.env.DATABASE_URL
});

export async function query({
    text,
    values
}: {
    text: string,
    values: string[]
}) {
    const client = await db.connect();

    try {
        return await client.query({
            text,
            values
        });
    } finally {
        client.release();
    }
}

export async function logError({
    type,
    func,
    args,
    error
}: ErrorLog) {
    try {
        const q = `
        INSERT INTO error_logs (error_type, func, arguments, error)
        VALUES ($1::varchar, $2::varchar, $3::varchar, $4::varchar);
        `;

        void query({
            text: q,
            values: [type, func, args.join(", "), error]
        });
    } catch (error: unknown) {
        console.log("Unable to log error:", error);
    }
}
