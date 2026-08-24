START TRANSACTION;

DROP PROCEDURE create_user;

CREATE OR REPLACE FUNCTION create_user(
    IN p_email VARCHAR,
    IN p_password_hash VARCHAR,
    IN p_first_name VARCHAR,
    IN p_last_name VARCHAR,
    OUT p_user_id VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO users (email, password_hash, first_name, last_name)
    VALUES (p_email, p_password_hash, p_first_name, p_last_name)
    RETURNING user_id INTO p_user_id;
END;
$$;

COMMIT;
