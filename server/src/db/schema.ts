import {
  pgTable,
  uuid,
  integer,
  text,
  varchar,
  timestamp,
  date,
  boolean,
  jsonb,
  primaryKey,
  foreignKey,
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

const users = pgTable('users', {
  id: uuid()
    .primaryKey()
    .default(sql`uuidv7()`),
  email: varchar({ length: 255 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }),
  firstName: varchar('first_name', { length: 100 }),
  lastName: varchar('last_name', { length: 100 }),
  createdAt: timestamp('created_at', {
    withTimezone: true,
  })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp('updated_at', {
    withTimezone: true,
  })
    .notNull()
    .defaultNow(),
});

const workspaces = pgTable(
  'workspaces',
  {
    id: uuid()
      .primaryKey()
      .default(sql`uuidv7()`),
    name: varchar({ length: 255 }).notNull(),
    region: varchar({ length: 255 }).notNull(),
    createdBy: uuid('created_by').notNull(),
    createdAt: timestamp('created_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp('updated_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    foreignKey({
      name: 'fk_workspaces_users',
      columns: [table.createdBy],
      foreignColumns: [users.id],
    }),
  ]
);

const workspaceUsers = pgTable(
  'workspace_users',
  {
    workspaceId: uuid('workspace_id').notNull(),
    userId: uuid('user_id').notNull(),
    joinedAt: timestamp('joined_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.workspaceId, table.userId],
    }),

    foreignKey({
      name: 'fk_workspace_users_workspaces',
      columns: [table.workspaceId],
      foreignColumns: [workspaces.id],
    }),

    foreignKey({
      name: 'fk_workspace_users_users',
      columns: [table.userId],
      foreignColumns: [users.id],
    }),
  ]
);

const labels = pgTable('labels', {
  id: uuid()
    .primaryKey()
    .default(sql`uuidv7()`),
  name: varchar({ length: 255 }).notNull(),
  labelType: varchar('label_type', { length: 30 }),
});

const properties = pgTable('properties', {
  id: uuid()
    .primaryKey()
    .default(sql`uuidv7()`),
  name: varchar({ length: 30 }).notNull(),
  description: varchar({ length: 80 }),
  isSystem: boolean('is_system').default(false),
  propertyType: varchar('property_type', { length: 30 }).notNull(),
});

const propertyOptions = pgTable(
  'property_options',
  {
    id: uuid()
      .primaryKey()
      .default(sql`uuidv7()`),
    propertyId: uuid('property_id').notNull(),
    label: varchar({ length: 30 }).notNull(),
    value: varchar({ length: 255 }).notNull(),
    displayOrder: integer('display_order').default(0),
    createdByUserId: uuid('created_by_user_id'),
  },
  (table) => [
    foreignKey({
      name: 'fk_property_options_properties',
      columns: [table.propertyId],
      foreignColumns: [properties.id],
    }),

    foreignKey({
      name: 'fk_property_options_users',
      columns: [table.createdByUserId],
      foreignColumns: [users.id],
    }),
  ]
);

const links = pgTable('links', {
  id: uuid()
    .primaryKey()
    .default(sql`uuidv7()`),
  url: varchar({ length: 4096 }).notNull(),
  title: text(),
  createdAt: timestamp('created_at', {
    withTimezone: true,
  })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp('updated_at', {
    withTimezone: true,
  })
    .notNull()
    .defaultNow(),
});

const projects = pgTable(
  'projects',
  {
    id: uuid()
      .primaryKey()
      .default(sql`uuidv7()`),
    name: varchar({ length: 80 }).notNull(),
    summary: varchar({ length: 255 }),
    description: text(),
    startDate: date('start_date'),
    targetDate: date('target_date'),
    leadId: uuid('lead_id'),
    workspaceId: uuid('workspace_id').notNull(),
    createdBy: uuid('created_by').notNull(),
    createdAt: timestamp('created_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp('updated_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    foreignKey({
      name: 'fk_projects_users_lead_id',
      columns: [table.leadId],
      foreignColumns: [users.id],
    }),

    foreignKey({
      name: 'fk_projects_users_created_by',
      columns: [table.createdBy],
      foreignColumns: [users.id],
    }),

    foreignKey({
      name: 'fk_projects_workspaces',
      columns: [table.workspaceId],
      foreignColumns: [workspaces.id],
    }),
  ]
);

const projectLinks = pgTable(
  'project_links',
  {
    projectId: uuid('project_id').notNull(),
    linkId: uuid('link_id').notNull(),
  },
  (table) => [
    primaryKey({
      columns: [table.projectId, table.linkId],
    }),

    foreignKey({
      name: 'fk_project_links_projects',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),

    foreignKey({
      name: 'fk_project_links_links',
      columns: [table.linkId],
      foreignColumns: [links.id],
    }),
  ]
);

const projectMembers = pgTable(
  'project_members',
  {
    projectId: uuid('project_id').notNull(),
    memberId: uuid('member_id').notNull(),
    joinedAt: timestamp('joined_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.projectId, table.memberId],
    }),

    foreignKey({
      name: 'fk_project_members_projects',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),

    foreignKey({
      name: 'fk_project_members_users',
      columns: [table.memberId],
      foreignColumns: [users.id],
    }),
  ]
);

const projectDependencies = pgTable(
  'project_dependencies',
  {
    projectId: uuid('project_id').notNull(),
    dependencyId: uuid('dependency_id').notNull(),
    dependencyType: varchar('dependency_type', {
      length: 30,
    }).notNull(),
  },
  (table) => [
    primaryKey({
      columns: [table.projectId, table.dependencyId],
    }),

    foreignKey({
      name: 'fk_project_dependencies_projects_project_id',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),

    foreignKey({
      name: 'fk_project_dependencies_projects_dependency_id',
      columns: [table.dependencyId],
      foreignColumns: [projects.id],
    }),
  ]
);

const projectLabels = pgTable(
  'project_labels',
  {
    projectId: uuid('project_id').notNull(),
    labelId: uuid('label_id').notNull(),
    addedAt: timestamp('added_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.projectId, table.labelId],
    }),

    foreignKey({
      name: 'fk_project_labels_projects',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),

    foreignKey({
      name: 'fk_project_labels_labels',
      columns: [table.labelId],
      foreignColumns: [labels.id],
    }),
  ]
);

const projectProperties = pgTable(
  'project_properties',
  {
    projectId: uuid('project_id').notNull(),
    propertyId: uuid('property_id').notNull(),
    addedAt: timestamp('added_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.projectId, table.propertyId],
    }),

    foreignKey({
      name: 'fk_project_properties_projects',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),

    foreignKey({
      name: 'fk_project_properties_properties',
      columns: [table.propertyId],
      foreignColumns: [properties.id],
    }),
  ]
);

const documents = pgTable(
  'documents',
  {
    id: uuid()
      .primaryKey()
      .default(sql`uuidv7()`),
    projectId: uuid('project_id').notNull(),
    title: varchar({ length: 512 }),
    createdAt: timestamp('created_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp('updated_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
    content: jsonb()
      .notNull()
      .default(sql`'[]'::jsonb`),
  },
  (table) => [
    foreignKey({
      name: 'fk_documents_projects',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),
  ]
);

const tasks = pgTable(
  'tasks',
  {
    id: uuid()
      .primaryKey()
      .default(sql`uuidv7()`),
    name: varchar({ length: 80 }).notNull(),
    description: text(),
    dueDate: date('due_date'),
    assignee: uuid(),
    parentTaskId: uuid('parent_task_id'),
  },
  (table) => [
    foreignKey({
      name: 'fk_tasks_users',
      columns: [table.assignee],
      foreignColumns: [users.id],
    }),

    foreignKey({
      name: 'fk_tasks',
      columns: [table.parentTaskId],
      foreignColumns: [table.id],
    }),
  ]
);

const taskLinks = pgTable(
  'task_links',
  {
    taskId: uuid('task_id').notNull(),
    linkId: uuid('link_id').notNull(),
  },
  (table) => [
    primaryKey({
      columns: [table.taskId, table.linkId],
    }),

    foreignKey({
      name: 'fk_task_links_tasks',
      columns: [table.taskId],
      foreignColumns: [tasks.id],
    }),

    foreignKey({
      name: 'fk_task_links_links',
      columns: [table.linkId],
      foreignColumns: [links.id],
    }),
  ]
);

const recurringTasks = pgTable(
  'recurring_tasks',
  {
    taskId: uuid('task_id').primaryKey(),
    firstDue: date('first_due').notNull(),
    interval: integer().notNull(),
    intervalType: varchar('interval_type', { length: 30 }).notNull(),
  },
  (table) => [
    foreignKey({
      name: 'fk_recurring_tasks_tasks',
      columns: [table.taskId],
      foreignColumns: [tasks.id],
    }),
  ]
);

const projectTasks = pgTable(
  'project_tasks',
  {
    projectId: uuid('project_id').notNull(),
    taskId: uuid('task_id').notNull(),
    addedAt: timestamp('added_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.projectId, table.taskId],
    }),

    foreignKey({
      name: 'fk_project_tasks_projects',
      columns: [table.projectId],
      foreignColumns: [projects.id],
    }),

    foreignKey({
      name: 'fk_project_tasks_tasks',
      columns: [table.taskId],
      foreignColumns: [tasks.id],
    }),
  ]
);

const taskProperties = pgTable(
  'task_properties',
  {
    taskId: uuid('task_id').notNull(),
    propertyId: uuid('property_id').notNull(),
    addedAt: timestamp('added_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.taskId, table.propertyId],
    }),

    foreignKey({
      name: 'fk_task_properties_tasks',
      columns: [table.taskId],
      foreignColumns: [tasks.id],
    }),

    foreignKey({
      name: 'fk_task_properties_properties',
      columns: [table.propertyId],
      foreignColumns: [properties.id],
    }),
  ]
);

const taskLabels = pgTable(
  'task_labels',
  {
    taskId: uuid('task_id').notNull(),
    labelId: uuid('label_id').notNull(),
    addedAt: timestamp('added_at', {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    primaryKey({
      columns: [table.taskId, table.labelId],
    }),

    foreignKey({
      name: 'fk_task_labels_tasks',
      columns: [table.taskId],
      foreignColumns: [tasks.id],
    }),

    foreignKey({
      name: 'fk_task_labels_labels',
      columns: [table.labelId],
      foreignColumns: [labels.id],
    }),
  ]
);

export {
  users,
  workspaces,
  workspaceUsers,
  labels,
  properties,
  propertyOptions,
  links,
  projects,
  projectLinks,
  projectMembers,
  projectDependencies,
  projectLabels,
  projectProperties,
  documents,
  tasks,
  taskLinks,
  recurringTasks,
  projectTasks,
  taskProperties,
  taskLabels,
};
