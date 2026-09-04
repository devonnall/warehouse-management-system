import 'reflect-metadata';
import * as dotenv from 'dotenv';
import express from 'express';
import cors from 'cors';
import session from 'express-session';
import connectPgSimple from 'connect-pg-simple';
import { pool } from './db/index.js';
import { usersRouter } from './routes/user.route.js';
import { authRouter } from './routes/auth.route.js';

dotenv.config();

const app = express();
const pgSession = connectPgSimple(session);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(
  cors({
    origin: `http://localhost:${process.env.PORT}`,
    credentials: true,
  })
);

app.use(
  session({
    store: new pgSession({
      pool: pool,
      tableName: 'sessions',
      createTableIfMissing: true,
    }),
    name: 'sid',
    secret: process.env.SESSION_SECRET || '',
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      secure: process.env.APP_ENV === 'production',
      maxAge: 1000 * 60 * 60 * 24,
      sameSite: 'lax',
    },
  })
);

app.use(usersRouter);
app.use(authRouter);

app.listen(3000, '0.0.0.0', () => {
  console.log(`Listening on port ${process.env.PORT}`);
});
