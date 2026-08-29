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
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE TABLE admins (
    user_id UUID PRIMARY KEY,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_admins_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE organizations (
    id UUID PRIMARY KEY default uuidv7(),
    name VARCHAR(255) NOT NULL,
    organization_type VARCHAR(30) NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(30),
    billing_address VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_organization_type
        CHECK (organization_type IN ('OPERATOR', 'CLIENT', 'VENDOR', 'BOTH'))
);

CREATE TABLE organization_users (
    organization_id UUID NOT NULL,
    user_id UUID NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (organization_id, user_id),

    CONSTRAINT fk_organization_users_organizations
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_organization_users_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE permissions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    CONSTRAINT uq_permissions_name UNIQUE (name)
);

CREATE TABLE roles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    CONSTRAINT uq_roles_name UNIQUE (name)
);

CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,

    PRIMARY KEY (role_id, permission_id),

    CONSTRAINT fk_role_permissions_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_permissions
        FOREIGN KEY (permission_id)
        REFERENCES permissions(id)
        ON DELETE CASCADE
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL,
    organization_id UUID NOT NULL,
    role_id INT NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, organization_id, role_id),

    CONSTRAINT fk_user_roles_membership
        FOREIGN KEY (user_id, organization_id)
        REFERENCES organization_users(user_id, organization_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE
);

CREATE TABLE organization_invitations (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    organization_id UUID NOT NULL,
    email VARCHAR(255) NOT NULL,
    role_id INT,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '1 week',
    invited_by UUID NOT NULL,

    CONSTRAINT fk_organization_invitations_organizations
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_organization_invitations_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
);

CREATE TABLE product_categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_category_id INT,

    CONSTRAINT uq_product_categories_name_parent
        UNIQUE (parent_category_id, name),

    CONSTRAINT fk_product_categories_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES product_categories(id)
        ON DELETE RESTRICT
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    client_id UUID NOT NULL,
    category_id INT,
    sku VARCHAR(100) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    unit_weight_kg NUMERIC(12,3),
    length_cm NUMERIC(10,2),
    width_cm NUMERIC(10,2),
    height_cm NUMERIC(10,2),
    reorder_threshold INT,
    is_lot_tracked BOOLEAN NOT NULL DEFAULT FALSE,
    is_perishable BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_proudcts_client
        FOREIGN KEY (client_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES product_categories(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_product_client_sku
        UNIQUE (client_id, sku),

    CONSTRAINT chk_product_weight
        CHECK (unit_weight_kg IS NULL OR unit_weight_kg >= 0),

    CONSTRAINT chk_products_dimensions
        CHECK (
            (length_cm IS NULL OR length_cm >= 0) AND
            (width_cm IS NULL OR width_cm >= 0) AND
            (height_cm IS NULL OR height_cm >= 0)
        ),

    CONSTRAINT chk_products_reorder_threshold
        CHECK (reorder_threshold IS NULL OR reorder_threshold >= 0)
);

CREATE TABLE warehouses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_warehouses_name UNIQUE (name)
);

CREATE TABLE locations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_id INT NOT NULL,
    location_code VARCHAR(100) NOT NULL,
    location_type VARCHAR(30) NOT NULL,
    max_weight_capacity_kg NUMERIC(12,3),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT fk_locations_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_locations_warehouse_code
        UNIQUE (warehouse_id, location_code),

    CONSTRAINT chk_locations_type
        CHECK (
            location_type IN (
                'RECEIVING',
                'STORAGE',
                'PICKING',
                'PACKING',
                'SHIPPING',
                'QUARANTINE',
                'DAMAGED'
            )
        ),

    CONSTRAINT chk_locations_capacity
        CHECK (
            max_weight_capacity_kg IS NULL
            OR max_weight_capacity_kg >= 0
        )
);

CREATE TABLE inventory_lots (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id UUID NOT NULL,
    lot_number VARCHAR(255) NOT NULL,
    manufacture_date DATE NOT NULL,
    expiration_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_lots_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_inventory_lots_product_number
        UNIQUE (product_id, lot_number),

    CONSTRAINT chk_inventory_lots_dates
        CHECK (
            expiration_date IS NULL
            OR expiration_date >= manufacture_date
        )
);

CREATE TABLE stock_balances (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    product_id UUID NOT NULL,
    location_id INT NOT NULL,
    lot_id INT,

    quantity_on_hand INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_stock_balances_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_stock_balances_location
        FOREIGN KEY (location_id)
        REFERENCES locations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_stock_balances_lot
        FOREIGN KEY (lot_id)
        REFERENCES inventory_lots(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_stock_balances
        UNIQUE (product_id, location_id, lot_id),

    CONSTRAINT chk_stock_balances_on_hand
        CHECK (quantity_on_hand >= 0),

    CONSTRAINT chk_stock_balances_reserved
        CHECK (
            quantity_reserved >= 0
            AND quantity_reserved <= quantity_on_hand
        )
);

CREATE TABLE inventory_transactions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    transaction_type VARCHAR(30) NOT NULL,

    reference_type VARCHAR(50),
    reference_id UUID,

    performed_by UUID,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_transactions_user
        FOREIGN KEY (performed_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_inventory_transaction_type
        CHECK (
            transaction_type IN (
                'RECEIPT',
                'TRANSFER',
                'PICK',
                'SHIPMENT',
                'ADJUSTMENT',
                'RETURN',
                'DAMAGE',
                'COUNT'
            )
        )
);

CREATE TABLE inventory_transaction_lines (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    transaction_id BIGINT NOT NULL,

    product_id UUID NOT NULL,
    lot_id INT,

    location_id INT NOT NULL,

    quantity_delta INT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_transaction_lines_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES inventory_transactions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_inventory_transaction_lines_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_inventory_transaction_lines_lot
        FOREIGN KEY (lot_id)
        REFERENCES inventory_lots(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_inventory_transaction_lines_location
        FOREIGN KEY (location_id)
        REFERENCES locations(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_inventory_transaction_lines_delta
        CHECK (quantity_delta <> 0)
);

CREATE TABLE inventory_reservations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_item_id INT NOT NULL,

    product_id UUID NOT NULL,
    lot_id INT,
    location_id INT NOT NULL,

    quantity INT NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMPTZ,

    CONSTRAINT fk_reservations_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reservations_lot
        FOREIGN KEY (lot_id)
        REFERENCES inventory_lots(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reservations_location
        FOREIGN KEY (location_id)
        REFERENCES locations(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_reservations_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_reservations_status
        CHECK (
            status IN ('ACTIVE', 'RELEASED', 'FULFILLED', 'CANCELLED')
        )
);

CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuidv7(),

    client_id UUID NOT NULL,
    vendor_id UUID NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',

    expected_delivery_date DATE,

    created_by UUID,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_purchase_orders_client
        FOREIGN KEY (client_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_purchase_orders_vendor
        FOREIGN KEY (vendor_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_purchase_orders_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_purchase_orders_status
        CHECK (
            status IN (
                'DRAFT',
                'SUBMITTED',
                'CONFIRMED',
                'PARTIALLY_RECEIVED',
                'RECEIVED',
                'CANCELLED'
            )
        )
);

CREATE TABLE po_line_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    po_id UUID NOT NULL,
    product_id UUID NOT NULL,

    quantity_expected INT NOT NULL,

    unit_cost NUMERIC(12,2),

    CONSTRAINT fk_po_line_items_po
        FOREIGN KEY (po_id)
        REFERENCES purchase_orders(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_po_line_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_po_line_items_quantity
        CHECK (quantity_expected > 0),

    CONSTRAINT chk_po_line_items_unit_cost
        CHECK (unit_cost IS NULL OR unit_cost >= 0)
);

CREATE TABLE receipts (
    id UUID PRIMARY KEY DEFAULT uuidv7(),

    po_id UUID NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'OPEN',

    received_by UUID,

    received_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_receipts_po
        FOREIGN KEY (po_id)
        REFERENCES purchase_orders(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_receipts_user
        FOREIGN KEY (received_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_receipts_status
        CHECK (
            status IN ('OPEN', 'COMPLETED', 'CANCELLED')
        )
);

CREATE TABLE receipt_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    receipt_id UUID NOT NULL,
    po_item_id BIGINT NOT NULL,

    product_id UUID NOT NULL,
    lot_id INT,

    location_id INT NOT NULL,

    quantity_received INT NOT NULL,

    CONSTRAINT fk_receipt_items_receipt
        FOREIGN KEY (receipt_id)
        REFERENCES receipts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_receipt_items_po_item
        FOREIGN KEY (po_item_id)
        REFERENCES po_line_items(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_receipt_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_receipt_items_lot
        FOREIGN KEY (lot_id)
        REFERENCES inventory_lots(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_receipt_items_location
        FOREIGN KEY (location_id)
        REFERENCES locations(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_receipt_items_quantity
        CHECK (quantity_received > 0)
);

CREATE TABLE sales_orders (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    client_id UUID NOT NULL,
    order_type VARCHAR(30) NOT NULL DEFAULT 'STANDARD',
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    shipping_address VARCHAR(500),
    created_by UUID,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sales_orders_client
        FOREIGN KEY (client_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_sales_orders_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_sales_orders_type
        CHECK (
            order_type IN ('STANDARD', 'RETURN', 'TRANSFER')
        ),

    CONSTRAINT chk_sales_orders_status
        CHECK (
            status IN (
                'DRAFT',
                'CONFIRMED',
                'ALLOCATED',
                'PICKING',
                'PACKED',
                'PARTIALLY_SHIPPED',
                'SHIPPED',
                'COMPLETED',
                'CANCELLED',
                'BACKORDERED'
            )
        )
);

CREATE TABLE order_line_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity_ordered INT NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_order_line_items_order
        FOREIGN KEY (order_id)
        REFERENCES sales_orders(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_order_line_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_order_line_items_quantity
        CHECK (quantity_ordered > 0),

    CONSTRAINT chk_order_line_items_unit_price
        CHECK (unit_price >= 0)
);

ALTER TABLE inventory_reservations
ADD CONSTRAINT fk_reservations_order_item
FOREIGN KEY (order_item_id)
REFERENCES order_line_items(id)
ON DELETE RESTRICT;

CREATE TABLE pick_tasks (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_item_id BIGINT NOT NULL,
    product_id UUID NOT NULL,
    lot_id INT,
    location_id INT NOT NULL,
    quantity_to_pick INT NOT NULL,
    quantity_picked INT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    assigned_to UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_pick_tasks_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_line_items(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pick_tasks_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pick_tasks_lot
        FOREIGN KEY (lot_id)
        REFERENCES inventory_lots(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pick_tasks_location
        FOREIGN KEY (location_id)
        REFERENCES locations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pick_tasks_user
        FOREIGN KEY (assigned_to)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_pick_tasks_quantity
        CHECK (
            quantity_to_pick > 0
            AND quantity_picked >= 0
            AND quantity_picked <= quantity_to_pick
        ),

    CONSTRAINT chk_pick_tasks_status
        CHECK (
            status IN (
                'PENDING',
                'ASSIGNED',
                'IN_PROGRESS',
                'COMPLETED',
                'CANCELLED'
            )
        )
);

CREATE TABLE shipments (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    order_id UUID NOT NULL,
    carrier_name VARCHAR(255),
    tracking_number VARCHAR(255),
    shipping_cost NUMERIC(12,2),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    shipped_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES sales_orders(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_shipments_cost
        CHECK (shipping_cost IS NULL OR shipping_cost >= 0),

    CONSTRAINT chk_shipments_status
        CHECK (
            status IN (
                'PENDING',
                'PACKED',
                'SHIPPED',
                'DELIVERED',
                'CANCELLED'
            )
        )
);

CREATE TABLE shipment_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id UUID NOT NULL,
    order_item_id BIGINT NOT NULL,
    product_id UUID NOT NULL,
    lot_id INT,
    quantity INT NOT NULL,

    CONSTRAINT fk_shipment_items_shipment
        FOREIGN KEY (shipment_id)
        REFERENCES shipments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_shipment_items_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_line_items(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_shipment_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_shipment_items_lot
        FOREIGN KEY (lot_id)
        REFERENCES inventory_lots(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_shipment_items_quantity
        CHECK (quantity > 0)
);

CREATE TABLE audit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID,
    organization_id UUID,
    entity_type VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_logs_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE SET NULL
);

CREATE TABLE error_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID,
    error_type VARCHAR(255),
    function_name VARCHAR(255),
    message TEXT,
    stack_trace TEXT,
    arguments JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_error_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);
