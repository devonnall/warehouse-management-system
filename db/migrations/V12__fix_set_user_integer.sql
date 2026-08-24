START TRANSACTION;

DROP PROCEDURE set_user_role;

CREATE PROCEDURE set_user_role(p_user_id UUID, p_role VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE
    has_role BOOLEAN;
    number_roles INTEGER;
    v_role_id roles.role_id%TYPE;
BEGIN
    SELECT role_id
    INTO v_role_id
    FROM roles
    WHERE name = p_role;

    SELECT COUNT(*)
    INTO number_roles
    FROM user_roles
    WHERE user_id = p_user_id;

    IF number_roles == 0 THEN
        INSERT INTO user_roles(role_id, user_id)
        VALUES (v_role_id, p_user_id);
    ELSE
        UPDATE user_roles
        SET role_id = v_role_id
        WHERE user_id = p_user_id;
    END IF;
END;
$$;

COMMIT;
