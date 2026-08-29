import {
    pgTable,
    uuid,
    integer,
    bigint,
    numeric,
    text,
    varchar,
    timestamp,
    date,
    boolean,
    jsonb,
    primaryKey,
    foreignKey,
    unique
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

export const users = pgTable("users", {
    id: uuid().primaryKey().default(sql`uuidv7()`),
    email: varchar({ length: 255 }).notNull().unique(),
    passwordHash: varchar("password_hash", { length: 255 }).notNull(),
    firstName: varchar("first_name", { length: 100 }).notNull(),
    lastName: varchar("last_name", { length: 100 }).notNull(),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true
    }).notNull().defaultNow()
});

export const admins = pgTable("admins", {
    userId: uuid("user_id")
        .primaryKey(),
    assignedAt: timestamp("assigned_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_admins_users",
        columns: [table.userId],
        foreignColumns: [users.id]
    })
]);

export const organizations = pgTable("organizations", {
    id: uuid().primaryKey().default(sql`uuidv7()`),
    name: varchar({ length: 255 }).notNull(),
    organizationType: varchar("organization_type", { 
        length: 30 
    }).notNull(),
    contactEmail: varchar("contact_email", {
        length: 255
    }),
    contactPhone: varchar("contact_phone", {
        length: 30
    }),
    billingAddress: varchar("billing_address", {
        length: 255
    }),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true
    }).notNull().defaultNow()
});

export const organizationUsers = pgTable("organization_users", {
    organizationId: uuid("organization_id")
        .notNull(),
    userId: uuid("user_id")
        .notNull(),
    joinedAt: timestamp("joined_at", {
            withTimezone: true
        }).notNull().defaultNow(),
    isActive: boolean("is_active").notNull().default(true)
}, (table) => [
    primaryKey({
        columns: [table.organizationId, table.userId]
    }),
    foreignKey({
        name: "fk_organization_users_organizations",
        columns: [table.organizationId],
        foreignColumns: [organizations.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_organization_users_users",
        columns: [table.userId],
        foreignColumns: [users.id]
    }).onDelete("cascade")
]);

export const permissions = pgTable("permissions", {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    name: varchar({ length: 100 }).notNull().unique(),
    description: text()
});

export const roles = pgTable("roles", {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    name: varchar({ length: 100 }).notNull().unique(),
    description: text()
});

export const rolePermissions = pgTable("role_permissions", {
    roleId: integer("role_id")
        .notNull(),
    permissionId: integer("permission_id")
        .notNull()
}, (table) => [
    primaryKey({
        columns: [table.roleId, table.permissionId]
    }),
    foreignKey({
        name: "fk_role_permissions_roles",
        columns: [table.roleId],
        foreignColumns: [roles.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_role_permissions_permissions",
        columns: [table.permissionId],
        foreignColumns: [permissions.id]
    }).onDelete("cascade")
]);

export const userRoles = pgTable("user_roles", {
    userId: uuid("user_id").notNull(),
    organizationId: uuid("organization_id").notNull(),
    roleId: integer("role_id").notNull(),
    assigedAt: timestamp("assigned_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    primaryKey({
        columns: [table.userId, table.organizationId, table.roleId]
    }),
    foreignKey({
        name: "fk_user_roles_membership",
        columns: [table.userId, table.organizationId],
        foreignColumns: [organizationUsers.userId, organizationUsers.organizationId]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_user_roles_roles",
        columns: [table.roleId],
        foreignColumns: [roles.id]
    }).onDelete("cascade")
]);

export const productCategories = pgTable("product_categories", {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    name: varchar({ length: 255 }).notNull().unique(),
    parentCategoryId: integer("parent_category_id")
}, (table) => [
    foreignKey({
        name: "fk_product_categories_parent",
        columns: [table.parentCategoryId],
        foreignColumns: [table.id]
    })
]);

export const products = pgTable("products", {
    id: uuid().primaryKey().default(sql`uuidv7()`),
    clientId: uuid("client_id").notNull(),
    categoryId: integer("category_id"),
    sku: varchar({ length: 100 }).notNull().unique(),
    productName: varchar({ length: 255 }).notNull(),
    description: text(),
    unitWeightKg: numeric("unit_weight_kg", {
        precision: 12,
        scale: 3
    }),
    lengthCm: numeric("length_cm", {
        precision: 10,
        scale: 2
    }),
    widthCm: numeric("width_cm", {
        precision: 10,
        scale: 2
    }),
    heightCm: numeric("height_cm", {
        precision: 10,
        scale: 2
    }),
    reorderThreshold: integer("reorder_threshold"),
    isLotTracked: boolean("is_lot_tracked").notNull().default(false),
    isPerishable: boolean("is_perishable").notNull().default(false),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_products_client",
        columns: [table.clientId],
        foreignColumns: [organizations.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_product_category",
        columns: [table.categoryId],
        foreignColumns: [productCategories.id]
    }).onDelete("set null")
]);

export const warehouses = pgTable("warehouses", {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    name: varchar({ length: 255 }).notNull().unique(),
    address: varchar({ length: 255 }),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
});

export const locations = pgTable("locations", {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    warehouseId: integer("warehouse_id").notNull(),
    locationCode: varchar("location_code", { length: 100 }).notNull(),
    locationType: varchar("location_type", { length: 30 }).notNull(),
    maxWeightCapacityKg: numeric("max_weight_capacity_kg", {
        precision: 12,
        scale: 3
    }),
    isActive: boolean("is_active").notNull().default(true)
}, (table) => [
    foreignKey({
        name: "fk_locations_warehouse",
        columns: [table.warehouseId],
        foreignColumns: [warehouses.id]
    }),
    unique("uq_locations_warehouse_code")
        .on(table.warehouseId, table.locationCode)
]);

export const inventoryLots = pgTable("inventory_lots", {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    productId: uuid("product_id").notNull(),
    lotNumber: varchar("lot_number", {
        length: 255
    }).notNull(),
    manufactureDate: date("manufacture_date").notNull(),
    expirationDate: date("expiration_date"),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_inventory_lots_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    unique("uq_inventory_lots_product_number")
        .on(table.productId, table.lotNumber)
]);

export const stockBalances = pgTable("stock_balances", {
    id: bigint({ mode: "number" }).primaryKey().generatedAlwaysAsIdentity(),
    productId: uuid("product_id").notNull(),
    locationId: integer("location_id").notNull(),
    lotId: integer("lot_id"),
    quantityOnHand: integer("quantity_on_hand").notNull().default(0),
    quantityReserved: integer("quantity_reserved").notNull().default(0),
    updatedAt: timestamp("updated_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_stock_balances_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_stock_balances_location",
        columns: [table.locationId],
        foreignColumns: [locations.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_stock_balances_lot",
        columns: [table.lotId],
        foreignColumns: [inventoryLots.id]
    }).onDelete("restrict"),
    unique("uq_stock_balances")
        .on(table.productId, table.locationId, table.lotId)
]);

export const inventoryTransactions = pgTable("inventory_transactions", {
    id: bigint({ mode: "number" }).primaryKey().generatedAlwaysAsIdentity(),
    transactionType: varchar("transaction_type", {
        length: 30
    }).notNull(),
    referenceType: varchar("reference_type", {
        length: 50
    }),
    referenceId: uuid("reference_id"),
    performedBy: uuid("performed_by"),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_inventory_transactions_user",
        columns: [table.performedBy],
        foreignColumns: [users.id]
    }).onDelete("set null")
]);

export const inventoryTransactionLines = pgTable("inventory_transaction_lines", {
    id: bigint({ mode: "number" }).primaryKey().generatedAlwaysAsIdentity(),
    transactionId: bigint("transaction_id", { mode: "number" }).notNull(),
    productId: uuid("product_id").notNull(),
    lotId: integer("lot_id"),
    locationId: integer("location_id").notNull(),
    quantityDelta: integer("quantity_delta").notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_inventory_transaction_lines_transaction",
        columns: [table.transactionId],
        foreignColumns: [inventoryTransactions.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_inventory_transaction_lines_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_inventory_transaction_lines_lot",
        columns: [table.lotId],
        foreignColumns: [inventoryLots.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_inventory_transaction_lines_location",
        columns: [table.locationId],
        foreignColumns: [locations.id]
    }).onDelete("restrict")
]);

export const inventoryReservations = pgTable("inventory_reservations", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    orderItemId: bigint("order_item_id", { mode: "number" })
        .notNull(),
    productId: uuid("product_id")
        .notNull(),
    lotId: integer("lot_id"),
    locationId: integer("location_id")
        .notNull(),
    quantity: integer()
        .notNull(),
    status: varchar({ length: 30 })
        .notNull()
        .default("ACTIVE"),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow(),
    releasedAt: timestamp("released_at", {
        withTimezone: true
    })
}, (table) => [
    foreignKey({
        name: "fk_reservat[118;1:3uions_order_item",
        columns: [table.orderItemId],
        foreignColumns: [orderLineItems.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_reservations_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_reservations_lot",
        columns: [table.lotId],
        foreignColumns: [inventoryLots.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_reservations_location",
        columns: [table.locationId],
        foreignColumns: [locations.id]
    }).onDelete("restrict")
]);

export const purchaseOrders = pgTable("purchase_orders", {
    id: uuid()
        .primaryKey()
        .default(sql`uuidv7()`),
    clientId: uuid("client_id")
        .notNull(),
    vendorId: uuid("vendor_id")
        .notNull(),
    status: varchar({ length: 30 })
        .notNull()
        .default("DRAFT"),
    expectedDeliveryDate: date("expected_delivery_date"),
    createdBy: uuid("created_by"),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_purchase_orders_client",
        columns: [table.clientId],
        foreignColumns: [organizations.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_purchase_orders_vendor",
        columns: [table.vendorId],
        foreignColumns: [organizations.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_purchase_orders_created_by",
        columns: [table.createdBy],
        foreignColumns: [users.id]
    }).onDelete("set null")
]);

export const poLineItems = pgTable("po_line_items", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    poId: uuid("po_id")
        .notNull(),
    productId: uuid("product_id")
        .notNull(),
    quantityExpected: integer("quantity_expected")
        .notNull(),
    unitCost: numeric("unit_cost", {
        precision: 12,
        scale: 2
    })
}, (table) => [
    foreignKey({
        name: "fk_po_line_items_po",
        columns: [table.poId],
        foreignColumns: [purchaseOrders.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_po_line_items_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict")
]);

export const receipts = pgTable("receipts", {
    id: uuid()
        .primaryKey()
        .default(sql`uuidv7()`),
    poId: uuid("po_id")
        .notNull(),
    status: varchar({ length: 30 })
        .notNull()
        .default("OPEN"),
    receivedBy: uuid("received_by"),
    receivedAt: timestamp("received_at", {
        withTimezone: true
    }),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_receipts_po",
        columns: [table.poId],
        foreignColumns: [purchaseOrders.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_receipts_user",
        columns: [table.receivedBy],
        foreignColumns: [users.id]
    }).onDelete("set null")
]);

export const receiptItems = pgTable("receipt_items", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    receiptId: uuid("receipt_id")
        .notNull(),
    poItemId: bigint("po_item_id", { mode: "number" })
        .notNull(),
    productId: uuid("product_id")
        .notNull(),
    lotId: integer("lot_id"),
    locationId: integer("location_id")
        .notNull(),
    quantityReceived: integer("quantity_received")
        .notNull()
}, (table) => [
    foreignKey({
        name: "fk_receipt_items_receipt",
        columns: [table.receiptId],
        foreignColumns: [receipts.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_receipt_items_po_item",
        columns: [table.poItemId],
        foreignColumns: [poLineItems.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_receipt_items_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_receipt_items_lot",
        columns: [table.lotId],
        foreignColumns: [inventoryLots.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_receipt_items_location",
        columns: [table.locationId],
        foreignColumns: [locations.id]
    }).onDelete("restrict")
]);

export const salesOrders = pgTable("sales_orders", {
    id: uuid()
        .primaryKey()
        .default(sql`uuidv7()`),
    clientId: uuid("client_id")
        .notNull(),
    orderType: varchar("order_type", {
        length: 30
    }).notNull().default("STANDARD"),
    status: varchar({ length: 30 })
        .notNull()
        .default("DRAFT"),
    shippingAddress: varchar("shipping_address", {
        length: 500
    }),
    createdBy: uuid("created_by"),
    orderDate: timestamp("order_date", {
        withTimezone: true
    }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_sales_orders_client",
        columns: [table.clientId],
        foreignColumns: [organizations.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_sales_orders_created_by",
        columns: [table.createdBy],
        foreignColumns: [users.id]
    }).onDelete("set null")
]);

export const orderLineItems = pgTable("order_line_items", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    orderId: uuid("order_id")
        .notNull(),
    productId: uuid("product_id")
        .notNull(),
    quantityOrdered: integer("quantity_ordered")
        .notNull(),
    unitPrice: numeric("unit_price", {
        precision: 12,
        scale: 2
    }).notNull()
}, (table) => [
    foreignKey({
        name: "fk_order_line_items_order",
        columns: [table.orderId],
        foreignColumns: [salesOrders.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_order_line_items_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict")
]);

export const pickTasks = pgTable("pick_tasks", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    orderItemId: bigint("order_item_id", { mode: "number" })
        .notNull(),
    productId: uuid("product_id")
        .notNull(),
    lotId: integer("lot_id"),
    locationId: integer("location_id")
        .notNull(),
    quantityToPick: integer("quantity_to_pick")
        .notNull(),
    quantityPicked: integer("quantity_picked")
        .notNull()
        .default(0),
    status: varchar({ length: 30 })
        .notNull()
        .default("PENDING"),
    assignedTo: uuid("assigned_to"),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow(),
    startedAt: timestamp("started_at", {
        withTimezone: true
    }),
    completedAt: timestamp("completed_at", {
        withTimezone: true
    })
}, (table) => [
    foreignKey({
        name: "fk_pick_tasks_order_item",
        columns: [table.orderItemId],
        foreignColumns: [orderLineItems.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_pick_tasks_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_pick_tasks_lot",
        columns: [table.lotId],
        foreignColumns: [inventoryLots.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_pick_tasks_location",
        columns: [table.locationId],
        foreignColumns: [locations.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_pick_tasks_user",
        columns: [table.assignedTo],
        foreignColumns: [users.id]
    }).onDelete("set null")
]);

export const shipments = pgTable("shipments", {
    id: uuid()
        .primaryKey()
        .default(sql`uuidv7()`),
    orderId: uuid("order_id")
        .notNull(),
    carrierName: varchar("carrier_name", {
        length: 255
    }),
    trackingNumber: varchar("tracking_number", {
        length: 255
    }),
    shippingCost: numeric("shipping_cost", {
        precision: 12,
        scale: 2
    }),
    status: varchar({ length: 30 })
        .notNull()
        .default("PENDING"),
    shippedAt: timestamp("shipped_at", {
        withTimezone: true
    }),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_shipments_order",
        columns: [table.orderId],
        foreignColumns: [salesOrders.id]
    }).onDelete("restrict")
]);

export const shipmentItems = pgTable("shipment_items", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    shipmentId: uuid("shipment_id")
        .notNull(),
    orderItemId: bigint("order_item_id", { mode: "number" })
        .notNull(),
    productId: uuid("product_id")
        .notNull(),
    lotId: integer("lot_id"),
    quantity: integer()
        .notNull()
}, (table) => [
    foreignKey({
        name: "fk_shipment_items_shipment",
        columns: [table.shipmentId],
        foreignColumns: [shipments.id]
    }).onDelete("cascade"),
    foreignKey({
        name: "fk_shipment_items_order_item",
        columns: [table.orderItemId],
        foreignColumns: [orderLineItems.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_shipment_items_product",
        columns: [table.productId],
        foreignColumns: [products.id]
    }).onDelete("restrict"),
    foreignKey({
        name: "fk_shipment_items_lot",
        columns: [table.lotId],
        foreignColumns: [inventoryLots.id]
    }).onDelete("restrict")
]);

export const auditLogs = pgTable("audit_logs", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    userId: uuid("user_id"),
    organizationId: uuid("organization_id"),
    entityType: varchar("entity_type", {
        length: 100
    }).notNull(),
    entityId: varchar("entity_id", {
        length: 100
    }).notNull(),
    action: varchar({ length: 50 })
        .notNull(),
    oldValues: jsonb("old_values"),
    newValues: jsonb("new_values"),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_audit_logs_user",
        columns: [table.userId],
        foreignColumns: [users.id]
    }).onDelete("set null"),
    foreignKey({
        name: "fk_audit_logs_organization",
        columns: [table.organizationId],
        foreignColumns: [organizations.id]
    }).onDelete("set null")
]);

export const errorLogs = pgTable("error_logs", {
    id: bigint({ mode: "number" })
        .primaryKey()
        .generatedAlwaysAsIdentity(),
    userId: uuid("user_id"),
    errorType: varchar("error_type", {
        length: 255
    }),
    functionName: varchar("function_name", {
        length: 255
    }),
    message: text(),
    stackTrace: text("stack_trace"),
    arguments: jsonb(),
    metadata: jsonb(),
    createdAt: timestamp("created_at", {
        withTimezone: true
    }).notNull().defaultNow()
}, (table) => [
    foreignKey({
        name: "fk_error_logs_user",
        columns: [table.userId],
        foreignColumns: [users.id]
    }).onDelete("set null")
]);
