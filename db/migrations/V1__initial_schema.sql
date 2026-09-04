CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE "sessions" (
    "sid" VARCHAR NOT NULL COLLATE "default",
    "sess" JSON NOT NULL,
    "expire" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE
)
WITH (OIDS=FALSE);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE TABLE workspaces (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_workspaces_users
        FOREIGN KEY (created_by)
        REFERENCES users(id)
);

CREATE TABLE workspace_users (
    workspace_id UUID NOT NULL,
    user_id UUID NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (workspace_id, user_id),

    CONSTRAINT fk_workspace_users_workspaces
        FOREIGN KEY (workspace_id)
        REFERENCES workspaces(id),

    CONSTRAINT fk_workspace_users_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);

CREATE TABLE labels (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(80) NOT NULL,
    label_type VARCHAR(30),

    CONSTRAINT chk_label_type 
        CHECK (label_type IN ('project', 'task'))
);

CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(30) NOT NULL,
    description VARCHAR(80),
    is_system BOOLEAN DEFAULT FALSE,
    property_type VARCHAR(30) NOT NULL,

    CONSTRAINT chk_property_type 
        CHECK (property_type IN ('project', 'task'))
);

CREATE TABLE property_options (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    property_id UUID NOT NULL,
    label VARCHAR(30) NOT NULL,
    value VARCHAR(255) NOT NULL,
    display_order INT DEFAULT 0,
    created_by_user_id UUID,
    
    CONSTRAINT fk_property_options_properties
        FOREIGN KEY (property_id) 
        REFERENCES properties(id),

    CONSTRAINT fk_property_options_users
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id)
);

CREATE TABLE links (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    url VARCHAR(4096) NOT NULL,
    title TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(80) NOT NULL,
    summary VARCHAR(255),
    description TEXT,
    start_date DATE,
    target_date DATE,
    lead_id UUID,
    workspace_id UUID NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_projects_users_lead_id
        FOREIGN KEY (lead_id)
        REFERENCES users(id),

    CONSTRAINT fk_projects_users_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id),

    CONSTRAINT fk_projects_workspaces
        FOREIGN KEY (workspace_id)
        REFERENCES workspaces(id)
);

CREATE TABLE project_links (
    project_id UUID NOT NULL,
    link_id UUID NOT NULL,

    PRIMARY KEY (project_id, link_id),

    CONSTRAINT fk_project_links_projects
        FOREIGN KEY (project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_project_links_links
        FOREIGN KEY (link_id)
        REFERENCES links(id)
);

CREATE TABLE project_members (
    project_id UUID NOT NULL,
    member_id UUID NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id, member_id),

    CONSTRAINT fk_project_members_projects
        FOREIGN KEY (project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_project_members_users
        FOREIGN KEY (member_id)
        REFERENCES users(id)
);

CREATE TABLE project_dependencies (
    project_id UUID NOT NULL,
    dependency_id UUID NOT NULL,
    dependency_type VARCHAR(30) NOT NULL,

    PRIMARY KEY (project_id, dependency_id),

    CONSTRAINT fk_project_dependencies_projects_project_id
        FOREIGN KEY (project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_project_dependencies_projects_dependency_id
        FOREIGN KEY (dependency_id)
        REFERENCES projects(id),

    CONSTRAINT chk_dependency_type 
        CHECK (dependency_type IN ('blocking', 'blocked by'))
);

CREATE TABLE project_labels (
    project_id UUID NOT NULL,
    label_id UUID NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id, label_id),

    CONSTRAINT fk_project_labels_projects
        FOREIGN KEY (project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_project_labels_labels
        FOREIGN KEY (label_id)
        REFERENCES labels(id)
);

CREATE TABLE project_properties (
    project_id UUID NOT NULL,
    property_id UUID NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id, property_id),

    CONSTRAINT fk_project_properties_projects
        FOREIGN KEY (project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_project_properties_properties
        FOREIGN KEY (property_id)
        REFERENCES properties(id)
);

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    project_id UUID NOT NULL,
    title VARCHAR(512),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT fk_documents_projects
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(80) NOT NULL,
    description TEXT,
    due_date DATE,
    assignee UUID,
    parent_task_id UUID,

    CONSTRAINT fk_tasks_users
        FOREIGN KEY (assignee)
        REFERENCES users(id),

    CONSTRAINT fk_tasks
        FOREIGN KEY (parent_task_id)
        REFERENCES tasks(id)
);

CREATE TABLE task_links (
    task_id UUID NOT NULL,
    link_id UUID NOT NULL,

    PRIMARY KEY (task_id, link_id),

    CONSTRAINT fk_task_links_tasks
        FOREIGN KEY (task_id)
        REFERENCES tasks(id),

    CONSTRAINT fk_task_links_links
        FOREIGN KEY (link_id)
        REFERENCES links(id)
);

CREATE TABLE recurring_tasks (
    task_id UUID PRIMARY KEY,
    first_due DATE NOT NULL,
    interval INT NOT NULL,
    interval_type VARCHAR(30) NOT NULL,

    CONSTRAINT fk_recurring_tasks_tasks
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
);

CREATE TABLE project_tasks (
    project_id UUID NOT NULL,
    task_id UUID NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id, task_id),

    CONSTRAINT fk_project_tasks_projects
        FOREIGN KEY (project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_project_tasks_tasks
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
);

CREATE TABLE task_properties (
    task_id UUID NOT NULL,
    property_id UUID NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (task_id, property_id),

    CONSTRAINT fk_task_properties_tasks
        FOREIGN KEY (task_id)
        REFERENCES tasks(id),

    CONSTRAINT fk_task_properties_properties
        FOREIGN KEY (property_id)
        REFERENCES properties(id)
);

CREATE TABLE task_labels (
    task_id UUID NOT NULL,
    label_id UUID NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (task_id, label_id),

    CONSTRAINT fk_task_labels_tasks
        FOREIGN KEY (task_id)
        REFERENCES tasks(id),

    CONSTRAINT fk_task_labels_labels
        FOREIGN KEY (label_id)
        REFERENCES labels(id)
);
