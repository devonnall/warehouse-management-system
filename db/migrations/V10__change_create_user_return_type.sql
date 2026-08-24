START TRANSACTION;

DROP FUNCTION create_user(
    IN p_email VARCHAR,
    IN p_password_hash VARCHAR,
    IN p_first_name VARCHAR,
    IN p_last_name VARCHAR,
    IN p_role VARCHAR,
    OUT p_user_id UUID
);

CREATE FUNCTION create_user(
    IN p_email VARCHAR,
    IN p_password_hash VARCHAR,
    IN p_first_name VARCHAR,
    IN p_last_name VARCHAR,
    IN p_role VARCHAR,
    OUT p_user_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_role_id roles.role_id%TYPE;
BEGIN
    INSERT INTO users (email, password_hash, first_name, last_name)
    VALUES (p_email, p_password_hash, p_first_name, p_last_name)
    RETURNING user_id INTO p_user_id;

    SELECT role_id
    INTO v_role_id
    FROM roles
    WHERE name = p_role;

    INSERT INTO user_roles (role_id, user_id)
    VALUES (v_role_id, p_user_id);
END;
$$;

COMMIT;
