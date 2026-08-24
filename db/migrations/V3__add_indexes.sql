START TRANSACTION;

CREATE INDEX "IDX_session_expire" ON "sessions" ("expire");

COMMIT;
