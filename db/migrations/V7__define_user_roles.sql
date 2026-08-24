START TRANSACTION;

INSERT INTO roles (name, description)
VALUES ('admin', 'The first account to be created is an administrator');

INSERT INTO roles (name, description)
VALUES ('manager', 'Manager of the warehouse');

INSERT INTO roles (name, description)
VALUES ('employee', 'Employee of the warehouse');

COMMIT;
