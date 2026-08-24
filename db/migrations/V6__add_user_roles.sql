START TRANSACTION;

CREATE TABLE roles (
    role_id UUID DEFAULT uuidv7(),
    name VARCHAR(100),
    description VARCHAR(255)
);

CREATE TABLE permissions (
    permission_id UUID DEFAULT uuidv7(),
    name VARCHAR(100),
    description VARCHAR(255)
);

CREATE TABLE user_roles (
    user_id UUID,
    role_id UUID
);

CREATE TABLE role_permissions (
    role_id UUID,
    permission_id UUID
);

ALTER TABLE roles
ADD CONSTRAINT pk_roles PRIMARY KEY (role_id);

ALTER TABLE permissions
ADD CONSTRAINT pk_permissions PRIMARY KEY (permission_id);

ALTER TABLE user_roles
ADD CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),
ADD CONSTRAINT fk_user_roles_users FOREIGN KEY (user_id)
    REFERENCES users(user_id),
ADD CONSTRAINT fk_user_roles_roles FOREIGN KEY (role_id)
    REFERENCES roles(role_id);

ALTER TABLE role_permissions
ADD CONSTRAINT pk_role_permissions PRIMARY KEY (role_id, permission_id),
ADD CONSTRAINT fk_role_permissions_roles FOREIGN KEY (role_id)
    REFERENCES roles(role_id),
ADD CONSTRAINT fk_role_permissions_permissions FOREIGN KEY (permission_id)
    REFERENCES permissions(permission_id);

COMMIT;
