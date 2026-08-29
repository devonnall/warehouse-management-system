BEGIN;

-- ============================================================
-- DEVELOPMENT SEED DATA
-- ============================================================
--
-- This script assumes the revised schema discussed previously.
--
-- It is intentionally destructive:
--   TRUNCATE ... CASCADE
--
-- All important UUIDs are deterministic so application tests can
-- reference known records.
--
-- Test password for every seeded user:
--   password
--
-- ============================================================


-- ============================================================
-- 1. CLEAR EXISTING DEVELOPMENT DATA
-- ============================================================

TRUNCATE TABLE
    audit_logs,
    inventory_transaction_lines,
    inventory_transactions,
    inventory_reservations,
    pick_tasks,
    shipment_items,
    shipments,
    order_line_items,
    sales_orders,
    receipt_items,
    receipts,
    po_line_items,
    purchase_orders,
    stock_balances,
    inventory_lots,
    products,
    product_categories,
    locations,
    warehouses,
    user_roles,
    role_permissions,
    permissions,
    roles,
    organization_users,
    organizations,
    error_logs,
    sessions,
    users
RESTART IDENTITY CASCADE;


-- ============================================================
-- 2. USERS
-- ============================================================

INSERT INTO users (
    id,
    email,
    password_hash,
    first_name,
    last_name,
    is_active
)
VALUES
    (
        '00000000-0000-0000-0000-000000000001',
        'alice@acmelogistics.test',
        crypt('password', gen_salt('bf')),
        'Alice',
        'Johnson',
        TRUE
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        'bob@acmelogistics.test',
        crypt('password', gen_salt('bf')),
        'Bob',
        'Smith',
        TRUE
    ),
    (
        '00000000-0000-0000-0000-000000000003',
        'carlos@acmelogistics.test',
        crypt('password', gen_salt('bf')),
        'Carlos',
        'Martinez',
        TRUE
    ),
    (
        '00000000-0000-0000-0000-000000000004',
        'diana@acmelogistics.test',
        crypt('password', gen_salt('bf')),
        'Diana',
        'Brown',
        TRUE
    ),

    -- Client A
    (
        '00000000-0000-0000-0000-000000000011',
        'dave@acmeproducts.test',
        crypt('password', gen_salt('bf')),
        'Dave',
        'Wilson',
        TRUE
    ),
    (
        '00000000-0000-0000-0000-000000000012',
        'erin@acmeproducts.test',
        crypt('password', gen_salt('bf')),
        'Erin',
        'Davis',
        TRUE
    ),

    -- Client B
    (
        '00000000-0000-0000-0000-000000000021',
        'frank@globex.test',
        crypt('password', gen_salt('bf')),
        'Frank',
        'Miller',
        TRUE
    ),
    (
        '00000000-0000-0000-0000-000000000022',
        'grace@globex.test',
        crypt('password', gen_salt('bf')),
        'Grace',
        'Taylor',
        TRUE
    ),

    -- Vendors
    (
        '00000000-0000-0000-0000-000000000031',
        'sales@partsco.test',
        crypt('password', gen_salt('bf')),
        'Henry',
        'Anderson',
        TRUE
    ),
    (
        '00000000-0000-0000-0000-000000000032',
        'sales@freshfoods.test',
        crypt('password', gen_salt('bf')),
        'Irene',
        'Thomas',
        TRUE
    );


-- ============================================================
-- 3. ORGANIZATIONS
-- ============================================================

INSERT INTO organizations (
    id,
    name,
    organization_type,
    contact_email,
    contact_phone,
    billing_address,
    is_active
)
VALUES
    (
        '10000000-0000-0000-0000-000000000001',
        'Acme Logistics',
        'OPERATOR',
        'contact@acmelogistics.test',
        '918-555-0100',
        '100 Warehouse Drive, Tulsa, OK 74101',
        TRUE
    ),
    (
        '10000000-0000-0000-0000-000000000002',
        'Acme Products',
        'CLIENT',
        'operations@acmeproducts.test',
        '918-555-0200',
        '200 Commerce Street, Tulsa, OK 74102',
        TRUE
    ),
    (
        '10000000-0000-0000-0000-000000000003',
        'Globex Manufacturing',
        'CLIENT',
        'warehouse@globex.test',
        '918-555-0300',
        '300 Industrial Avenue, Bartlesville, OK 74003',
        TRUE
    ),
    (
        '10000000-0000-0000-0000-000000000004',
        'PartsCo Supply',
        'VENDOR',
        'sales@partsco.test',
        '918-555-0400',
        '400 Supplier Road, Tulsa, OK 74104',
        TRUE
    ),
    (
        '10000000-0000-0000-0000-000000000005',
        'FreshFoods Distribution',
        'VENDOR',
        'sales@freshfoods.test',
        '918-555-0500',
        '500 Food Service Road, Tulsa, OK 74105',
        TRUE
    );


-- ============================================================
-- 4. ORGANIZATION MEMBERSHIPS
-- ============================================================

INSERT INTO organization_users (
    organization_id,
    user_id
)
VALUES
    -- Acme Logistics employees
    (
        '10000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001'
    ),
    (
        '10000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000002'
    ),
    (
        '10000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000003'
    ),
    (
        '10000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000004'
    ),

    -- Acme Products employees
    (
        '10000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000011'
    ),
    (
        '10000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000012'
    ),

    -- Globex employees
    (
        '10000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000021'
    ),
    (
        '10000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000022'
    ),

    -- Vendor users
    (
        '10000000-0000-0000-0000-000000000004',
        '00000000-0000-0000-0000-000000000031'
    ),
    (
        '10000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000032'
    );


-- ============================================================
-- 5. PERMISSIONS
-- ============================================================

INSERT INTO permissions (
    name,
    description
)
VALUES
    ('products.read', 'View products'),
    ('products.create', 'Create products'),
    ('products.update', 'Update products'),

    ('inventory.read', 'View inventory'),
    ('inventory.adjust', 'Adjust inventory'),
    ('inventory.transfer', 'Transfer inventory'),

    ('orders.read', 'View sales orders'),
    ('orders.create', 'Create sales orders'),
    ('orders.update', 'Update sales orders'),
    ('orders.cancel', 'Cancel sales orders'),

    ('purchasing.read', 'View purchase orders'),
    ('purchasing.create', 'Create purchase orders'),
    ('purchasing.update', 'Update purchase orders'),

    ('receiving.read', 'View receipts'),
    ('receiving.execute', 'Receive inventory'),

    ('picking.read', 'View pick tasks'),
    ('picking.execute', 'Execute pick tasks'),

    ('shipping.read', 'View shipments'),
    ('shipping.create', 'Create shipments'),

    ('warehouses.read', 'View warehouses'),
    ('warehouses.manage', 'Manage warehouses'),

    ('users.read', 'View users'),
    ('users.manage', 'Manage users'),

    ('roles.read', 'View roles'),
    ('roles.manage', 'Manage roles');


-- ============================================================
-- 6. ROLES
-- ============================================================

INSERT INTO roles (
    name,
    description
)
VALUES
    (
        'System Admin',
        'Full access to the WMS'
    ),
    (
        'Warehouse Manager',
        'Manages warehouse operations'
    ),
    (
        'Inventory Manager',
        'Manages inventory and adjustments'
    ),
    (
        'Picker',
        'Performs picking operations'
    ),
    (
        'Order Manager',
        'Manages sales orders'
    ),
    (
        'Client Admin',
        'Administrator for a client organization'
    ),
    (
        'Client User',
        'Standard client user'
    );


-- ============================================================
-- 7. ROLE PERMISSIONS
-- ============================================================

-- System Admin gets everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT
    r.id,
    p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'System Admin';


-- Warehouse Manager
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'products.read',
        'inventory.read',
        'inventory.adjust',
        'inventory.transfer',
        'orders.read',
        'purchasing.read',
        'receiving.read',
        'receiving.execute',
        'picking.read',
        'picking.execute',
        'shipping.read',
        'shipping.create',
        'warehouses.read',
        'warehouses.manage',
        'users.read'
    )
WHERE r.name = 'Warehouse Manager';


-- Inventory Manager
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'products.read',
        'products.create',
        'products.update',
        'inventory.read',
        'inventory.adjust',
        'inventory.transfer',
        'receiving.read',
        'receiving.execute',
        'warehouses.read'
    )
WHERE r.name = 'Inventory Manager';


-- Picker
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'inventory.read',
        'picking.read',
        'picking.execute'
    )
WHERE r.name = 'Picker';


-- Order Manager
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'products.read',
        'inventory.read',
        'orders.read',
        'orders.create',
        'orders.update',
        'orders.cancel',
        'shipping.read'
    )
WHERE r.name = 'Order Manager';


-- Client Admin
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'products.read',
        'products.create',
        'products.update',
        'inventory.read',
        'orders.read',
        'orders.create',
        'orders.update',
        'orders.cancel',
        'shipping.read',
        'users.read',
        'users.manage'
    )
WHERE r.name = 'Client Admin';


-- Client User
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'products.read',
        'inventory.read',
        'orders.read',
        'orders.create',
        'shipping.read'
    )
WHERE r.name = 'Client User';


-- ============================================================
-- 8. USER ROLES
-- ============================================================

-- Alice = System Admin
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    id
FROM roles
WHERE name = 'System Admin';


-- Bob = Warehouse Manager
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    id
FROM roles
WHERE name = 'Warehouse Manager';


-- Carlos = Inventory Manager
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000001',
    id
FROM roles
WHERE name = 'Inventory Manager';


-- Diana = Picker
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000004',
    '10000000-0000-0000-0000-000000000001',
    id
FROM roles
WHERE name = 'Picker';


-- Dave = Client Admin
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000011',
    '10000000-0000-0000-0000-000000000002',
    id
FROM roles
WHERE name = 'Client Admin';


-- Erin = Client User
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000012',
    '10000000-0000-0000-0000-000000000002',
    id
FROM roles
WHERE name = 'Client User';


-- Frank = Client Admin
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000021',
    '10000000-0000-0000-0000-000000000003',
    id
FROM roles
WHERE name = 'Client Admin';


-- Grace = Client User
INSERT INTO user_roles (
    user_id,
    organization_id,
    role_id
)
SELECT
    '00000000-0000-0000-0000-000000000022',
    '10000000-0000-0000-0000-000000000003',
    id
FROM roles
WHERE name = 'Client User';


-- ============================================================
-- 9. WAREHOUSES
-- ============================================================

INSERT INTO warehouses (
    id,
    name,
    address,
    is_active
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        1,
        'Tulsa Distribution Center',
        '100 Warehouse Drive, Tulsa, OK 74101',
        TRUE
    ),
    (
        2,
        'Bartlesville Distribution Center',
        '200 Warehouse Drive, Bartlesville, OK 74003',
        TRUE
    );


-- ============================================================
-- 10. LOCATIONS
-- ============================================================

INSERT INTO locations (
    id,
    warehouse_id,
    location_code,
    location_type,
    max_weight_capacity_kg,
    is_active
)
OVERRIDING SYSTEM VALUE
VALUES
    -- Tulsa receiving
    (
        1,
        1,
        'RECV-01',
        'RECEIVING',
        5000,
        TRUE
    ),

    -- Tulsa storage
    (
        2,
        1,
        'A-01-01-01',
        'STORAGE',
        1000,
        TRUE
    ),
    (
        3,
        1,
        'A-01-01-02',
        'STORAGE',
        1000,
        TRUE
    ),
    (
        4,
        1,
        'A-01-02-01',
        'STORAGE',
        750,
        TRUE
    ),
    (
        5,
        1,
        'A-02-01-01',
        'STORAGE',
        500,
        TRUE
    ),

    -- Tulsa picking
    (
        6,
        1,
        'PICK-01',
        'PICKING',
        500,
        TRUE
    ),
    (
        7,
        1,
        'PICK-02',
        'PICKING',
        500,
        TRUE
    ),

    -- Tulsa packing/shipping
    (
        8,
        1,
        'PACK-01',
        'PACKING',
        1000,
        TRUE
    ),
    (
        9,
        1,
        'SHIP-01',
        'SHIPPING',
        5000,
        TRUE
    ),

    -- Tulsa quarantine/damaged
    (
        10,
        1,
        'QUAR-01',
        'QUARANTINE',
        500,
        TRUE
    ),
    (
        11,
        1,
        'DAMAGED-01',
        'DAMAGED',
        500,
        TRUE
    ),

    -- Bartlesville
    (
        12,
        2,
        'RECV-01',
        'RECEIVING',
        5000,
        TRUE
    ),
    (
        13,
        2,
        'B-01-01-01',
        'STORAGE',
        1000,
        TRUE
    ),
    (
        14,
        2,
        'B-01-01-02',
        'STORAGE',
        1000,
        TRUE
    ),
    (
        15,
        2,
        'SHIP-01',
        'SHIPPING',
        5000,
        TRUE
    );


-- ============================================================
-- 11. PRODUCT CATEGORIES
-- ============================================================

INSERT INTO product_categories (
    id,
    name,
    parent_category_id
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        1,
        'Electronics',
        NULL
    ),
    (
        2,
        'Computer Accessories',
        1
    ),
    (
        3,
        'Cables',
        2
    ),
    (
        4,
        'Food & Beverage',
        NULL
    ),
    (
        5,
        'Snacks',
        4
    ),
    (
        6,
        'Industrial Parts',
        NULL
    ),
    (
        7,
        'Fasteners',
        6
    );


-- ============================================================
-- 12. PRODUCTS
-- ============================================================

INSERT INTO products (
    id,
    client_id,
    category_id,
    sku,
    product_name,
    description,
    unit_weight_kg,
    length_cm,
    width_cm,
    height_cm,
    reorder_threshold,
    is_lot_tracked,
    is_perishable,
    is_active
)
VALUES
    -- Acme Products
    (
        '20000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000002',
        3,
        'ACM-HDMI-6',
        '6ft HDMI Cable',
        'High-speed HDMI cable, 6 feet',
        0.15,
        20.00,
        15.00,
        5.00,
        50,
        FALSE,
        FALSE,
        TRUE
    ),
    (
        '20000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000002',
        2,
        'ACM-USB-C',
        'USB-C Charging Cable',
        'USB-C to USB-C charging cable',
        0.12,
        20.00,
        15.00,
        4.00,
        75,
        FALSE,
        FALSE,
        TRUE
    ),
    (
        '20000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002',
        2,
        'ACM-KEY-01',
        'Wireless Keyboard',
        'Compact wireless keyboard',
        0.65,
        35.00,
        15.00,
        4.00,
        20,
        FALSE,
        FALSE,
        TRUE
    ),

    -- Globex
    (
        '20000000-0000-0000-0000-000000000011',
        '10000000-0000-0000-0000-000000000003',
        7,
        'GLX-BOLT-M8',
        'M8 Hex Bolt',
        'Industrial grade M8 hex bolt',
        0.025,
        4.00,
        1.00,
        1.00,
        500,
        TRUE,
        FALSE,
        TRUE
    ),
    (
        '20000000-0000-0000-0000-000000000012',
        '10000000-0000-0000-0000-000000000003',
        7,
        'GLX-NUT-M8',
        'M8 Hex Nut',
        'Industrial grade M8 hex nut',
        0.01,
        2.00,
        2.00,
        1.00,
        500,
        TRUE,
        FALSE,
        TRUE
    ),

    -- Globex perishable product to demonstrate expiration
    (
        '20000000-0000-0000-0000-000000000013',
        '10000000-0000-0000-0000-000000000003',
        5,
        'GLX-PROTEIN',
        'Protein Snack Bar',
        'Chocolate protein snack bar',
        0.08,
        15.00,
        5.00,
        3.00,
        100,
        TRUE,
        TRUE,
        TRUE
    );


-- ============================================================
-- 13. INVENTORY LOTS
-- ============================================================

INSERT INTO inventory_lots (
    id,
    product_id,
    lot_number,
    manufacture_date,
    expiration_date
)
OVERRIDING SYSTEM VALUE
VALUES
    -- M8 bolts
    (
        1,
        '20000000-0000-0000-0000-000000000011',
        'BOLT-2026-001',
        '2026-01-15',
        NULL
    ),
    (
        2,
        '20000000-0000-0000-0000-000000000011',
        'BOLT-2026-002',
        '2026-05-10',
        NULL
    ),

    -- M8 nuts
    (
        3,
        '20000000-0000-0000-0000-000000000012',
        'NUT-2026-001',
        '2026-03-01',
        NULL
    ),

    -- Protein bars
    (
        4,
        '20000000-0000-0000-0000-000000000013',
        'PROTEIN-2026-01',
        '2026-06-01',
        '2026-12-01'
    ),
    (
        5,
        '20000000-0000-0000-0000-000000000013',
        'PROTEIN-2026-02',
        '2026-07-15',
        '2027-01-15'
    );


-- ============================================================
-- 14. PURCHASE ORDERS
-- ============================================================

INSERT INTO purchase_orders (
    id,
    client_id,
    vendor_id,
    status,
    expected_delivery_date,
    created_by
)
VALUES
    (
        '30000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000004',
        'PARTIALLY_RECEIVED',
        '2026-08-30',
        '00000000-0000-0000-0000-000000000003'
    ),
    (
        '30000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000005',
        'RECEIVED',
        '2026-08-20',
        '00000000-0000-0000-0000-000000000003'
    ),
    (
        '30000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000004',
        'CONFIRMED',
        '2026-09-05',
        '00000000-0000-0000-0000-000000000011'
    );


-- ============================================================
-- 15. PURCHASE ORDER LINE ITEMS
-- ============================================================

INSERT INTO po_line_items (
    id,
    po_id,
    product_id,
    quantity_expected,
    unit_cost
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        1,
        '30000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000011',
        2000,
        0.12
    ),
    (
        2,
        '30000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000012',
        2000,
        0.08
    ),
    (
        3,
        '30000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000013',
        1000,
        0.75
    ),
    (
        4,
        '30000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000001',
        500,
        3.50
    ),
    (
        5,
        '30000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000002',
        300,
        2.25
    );


-- ============================================================
-- 16. RECEIPTS
-- ============================================================

INSERT INTO receipts (
    id,
    po_id,
    status,
    received_by,
    received_at
)
VALUES
    (
        '40000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000001',
        'COMPLETED',
        '00000000-0000-0000-0000-000000000003',
        '2026-08-18 09:15:00-05'
    ),
    (
        '40000000-0000-0000-0000-000000000002',
        '30000000-0000-0000-0000-000000000001',
        'COMPLETED',
        '00000000-0000-0000-0000-000000000003',
        '2026-08-22 10:30:00-05'
    ),
    (
        '40000000-0000-0000-0000-000000000003',
        '30000000-0000-0000-0000-000000000002',
        'COMPLETED',
        '00000000-0000-0000-0000-000000000003',
        '2026-08-20 13:00:00-05'
    );


-- ============================================================
-- 17. RECEIPT ITEMS
-- ============================================================

INSERT INTO receipt_items (
    id,
    receipt_id,
    po_item_id,
    product_id,
    lot_id,
    location_id,
    quantity_received
)
OVERRIDING SYSTEM VALUE
VALUES
    -- First bolt delivery: 1200 of 2000
    (
        1,
        '40000000-0000-0000-0000-000000000001',
        1,
        '20000000-0000-0000-0000-000000000011',
        1,
        2,
        1200
    ),

    -- First nut delivery: 1000 of 2000
    (
        2,
        '40000000-0000-0000-0000-000000000001',
        2,
        '20000000-0000-0000-0000-000000000012',
        3,
        3,
        1000
    ),

    -- Second bolt delivery: another 500
    (
        3,
        '40000000-0000-0000-0000-000000000002',
        1,
        '20000000-0000-0000-0000-000000000011',
        2,
        4,
        500
    ),

    -- Protein bars: 1000 received
    (
        4,
        '40000000-0000-0000-0000-000000000003',
        3,
        '20000000-0000-0000-0000-000000000013',
        4,
        5,
        700
    ),
    (
        5,
        '40000000-0000-0000-0000-000000000003',
        3,
        '20000000-0000-0000-0000-000000000013',
        5,
        5,
        300
    );


-- ============================================================
-- 18. SALES ORDERS
-- ============================================================

INSERT INTO sales_orders (
    id,
    client_id,
    order_type,
    status,
    shipping_address,
    created_by,
    order_date
)
VALUES
    -- Order with picking in progress
    (
        '50000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000003',
        'STANDARD',
        'PICKING',
        '100 Manufacturing Way, Dallas, TX 75201',
        '00000000-0000-0000-0000-000000000021',
        '2026-08-24 09:00:00-05'
    ),

    -- Completed order
    (
        '50000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000002',
        'STANDARD',
        'COMPLETED',
        '200 Commerce Street, Tulsa, OK 74102',
        '00000000-0000-0000-0000-000000000011',
        '2026-08-20 11:00:00-05'
    ),

    -- Order awaiting allocation
    (
        '50000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002',
        'STANDARD',
        'CONFIRMED',
        '200 Commerce Street, Tulsa, OK 74102',
        '00000000-0000-0000-0000-000000000012',
        '2026-08-25 14:00:00-05'
    ),

    -- Partially shipped order
    (
        '50000000-0000-0000-0000-000000000004',
        '10000000-0000-0000-0000-000000000003',
        'STANDARD',
        'PARTIALLY_SHIPPED',
        '500 Industrial Park, Oklahoma City, OK 73101',
        '00000000-0000-0000-0000-000000000022',
        '2026-08-21 08:30:00-05'
    );


-- ============================================================
-- 19. ORDER LINE ITEMS
-- ============================================================

INSERT INTO order_line_items (
    id,
    order_id,
    product_id,
    quantity_ordered,
    unit_price
)
OVERRIDING SYSTEM VALUE
VALUES
    -- Order 1
    (
        1,
        '50000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000011',
        300,
        0.25
    ),
    (
        2,
        '50000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000012',
        300,
        0.18
    ),

    -- Order 2
    (
        3,
        '50000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000001',
        100,
        6.50
    ),
    (
        4,
        '50000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000002',
        50,
        4.50
    ),

    -- Order 3
    (
        5,
        '50000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000003',
        25,
        29.99
    ),

    -- Order 4
    (
        6,
        '50000000-0000-0000-0000-000000000004',
        '20000000-0000-0000-0000-000000000013',
        400,
        1.50
    );


-- ============================================================
-- 20. INVENTORY TRANSACTIONS
-- ============================================================

-- Receiving transaction #1
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        1,
        'RECEIPT',
        'RECEIPT',
        '40000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000003',
        '2026-08-18 09:15:00-05'
    );

-- Receiving transaction #2
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        2,
        'RECEIPT',
        'RECEIPT',
        '40000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000003',
        '2026-08-22 10:30:00-05'
    );

-- Receiving transaction #3
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        3,
        'RECEIPT',
        'RECEIPT',
        '40000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000003',
        '2026-08-20 13:00:00-05'
    );

-- Transfer transaction
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        4,
        'TRANSFER',
        'INTERNAL',
        NULL,
        '00000000-0000-0000-0000-000000000003',
        '2026-08-23 15:00:00-05'
    );

-- Picking transaction
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        5,
        'PICK',
        'SALES_ORDER',
        '50000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000004',
        '2026-08-21 10:00:00-05'
    );

-- Shipment transaction
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        6,
        'SHIPMENT',
        'SALES_ORDER',
        '50000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000002',
        '2026-08-21 16:00:00-05'
    );

-- Inventory adjustment
INSERT INTO inventory_transactions (
    id,
    transaction_type,
    reference_type,
    reference_id,
    performed_by,
    created_at
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        7,
        'ADJUSTMENT',
        'CYCLE_COUNT',
        NULL,
        '00000000-0000-0000-0000-000000000003',
        '2026-08-24 08:00:00-05'
    );


-- ============================================================
-- 21. INVENTORY TRANSACTION LINES
-- ============================================================

INSERT INTO inventory_transaction_lines (
    id,
    transaction_id,
    product_id,
    lot_id,
    location_id,
    quantity_delta
)
OVERRIDING SYSTEM VALUE
VALUES
    -- Receipt #1
    (
        1,
        1,
        '20000000-0000-0000-0000-000000000011',
        1,
        2,
        1200
    ),
    (
        2,
        1,
        '20000000-0000-0000-0000-000000000012',
        3,
        3,
        1000
    ),

    -- Receipt #2
    (
        3,
        2,
        '20000000-0000-0000-0000-000000000011',
        2,
        4,
        500
    ),

    -- Receipt #3
    (
        4,
        3,
        '20000000-0000-0000-0000-000000000013',
        4,
        5,
        700
    ),
    (
        5,
        3,
        '20000000-0000-0000-0000-000000000013',
        5,
        5,
        300
    ),

    -- Transfer: move 100 bolts from location 2 to location 6
    (
        6,
        4,
        '20000000-0000-0000-0000-000000000011',
        1,
        2,
        -100
    ),
    (
        7,
        4,
        '20000000-0000-0000-0000-000000000011',
        1,
        6,
        100
    ),

    -- Pick 100 HDMI cables
    (
        8,
        5,
        '20000000-0000-0000-0000-000000000001',
        NULL,
        2,
        -100
    ),

    -- Shipment
    (
        9,
        6,
        '20000000-0000-0000-0000-000000000001',
        NULL,
        8,
        -100
    ),

    -- Cycle-count adjustment: 5 fewer nuts than expected
    (
        10,
        7,
        '20000000-0000-0000-0000-000000000012',
        3,
        3,
        -5
    );


-- ============================================================
-- 22. CURRENT STOCK BALANCES
-- ============================================================

INSERT INTO stock_balances (
    id,
    product_id,
    location_id,
    lot_id,
    quantity_on_hand,
    quantity_reserved
)
OVERRIDING SYSTEM VALUE
VALUES
    -- M8 bolts
    (
        1,
        '20000000-0000-0000-0000-000000000011',
        2,
        1,
        1100,
        200
    ),
    (
        2,
        '20000000-0000-0000-0000-000000000011',
        4,
        2,
        500,
        0
    ),
    (
        3,
        '20000000-0000-0000-0000-000000000011',
        6,
        1,
        100,
        100
    ),

    -- M8 nuts
    (
        4,
        '20000000-0000-0000-0000-000000000012',
        3,
        3,
        995,
        300
    ),

    -- Protein bars
    (
        5,
        '20000000-0000-0000-0000-000000000013',
        5,
        4,
        700,
        250
    ),
    (
        6,
        '20000000-0000-0000-0000-000000000013',
        5,
        5,
        300,
        0
    );


-- ============================================================
-- 23. INVENTORY RESERVATIONS
-- ============================================================

INSERT INTO inventory_reservations (
    id,
    order_item_id,
    product_id,
    lot_id,
    location_id,
    quantity,
    status
)
OVERRIDING SYSTEM VALUE
VALUES
    -- Order 1: 200 bolts reserved
    (
        1,
        1,
        '20000000-0000-0000-0000-000000000011',
        1,
        2,
        100,
        'ACTIVE'
    ),
    (
        2,
        1,
        '20000000-0000-0000-0000-000000000011',
        1,
        6,
        100,
        'ACTIVE'
    ),

    -- Order 1: 300 nuts reserved
    (
        3,
        2,
        '20000000-0000-0000-0000-000000000012',
        3,
        3,
        300,
        'ACTIVE'
    ),

    -- Order 4: 250 protein bars reserved
    (
        4,
        6,
        '20000000-0000-0000-0000-000000000013',
        4,
        5,
        250,
        'ACTIVE'
    );


-- ============================================================
-- 24. PICK TASKS
-- ============================================================

INSERT INTO pick_tasks (
    id,
    order_item_id,
    product_id,
    lot_id,
    location_id,
    quantity_to_pick,
    quantity_picked,
    status,
    assigned_to,
    created_at,
    started_at
)
OVERRIDING SYSTEM VALUE
VALUES
    -- Bolt pick
    (
        1,
        1,
        '20000000-0000-0000-0000-000000000011',
        1,
        2,
        100,
        100,
        'COMPLETED',
        '00000000-0000-0000-0000-000000000004',
        '2026-08-24 09:00:00-05',
        '2026-08-24 09:15:00-05'
    ),

    -- Second bolt pick
    (
        2,
        1,
        '20000000-0000-0000-0000-000000000011',
        1,
        6,
        100,
        0,
        'IN_PROGRESS',
        '00000000-0000-0000-0000-000000000004',
        '2026-08-24 09:00:00-05',
        '2026-08-24 09:30:00-05'
    ),

    -- Nut pick
    (
        3,
        2,
        '20000000-0000-0000-0000-000000000012',
        3,
        3,
        300,
        0,
        'ASSIGNED',
        '00000000-0000-0000-0000-000000000004',
        '2026-08-24 09:00:00-05',
        NULL
    ),

    -- Protein bars
    (
        4,
        6,
        '20000000-0000-0000-0000-000000000013',
        4,
        5,
        250,
        0,
        'PENDING',
        NULL,
        '2026-08-25 09:00:00-05',
        NULL
    );


-- ============================================================
-- 25. SHIPMENTS
-- ============================================================

INSERT INTO shipments (
    id,
    order_id,
    carrier_name,
    tracking_number,
    shipping_cost,
    status,
    shipped_at
)
VALUES
    (
        '60000000-0000-0000-0000-000000000001',
        '50000000-0000-0000-0000-000000000002',
        'UPS',
        '1Z999AA10123456784',
        18.75,
        'DELIVERED',
        '2026-08-21 16:00:00-05'
    ),
    (
        '60000000-0000-0000-0000-000000000002',
        '50000000-0000-0000-0000-000000000004',
        'FedEx',
        '781234567890',
        24.50,
        'SHIPPED',
        '2026-08-23 14:00:00-05'
    );


-- ============================================================
-- 26. SHIPMENT ITEMS
-- ============================================================

INSERT INTO shipment_items (
    id,
    shipment_id,
    order_item_id,
    product_id,
    lot_id,
    quantity
)
OVERRIDING SYSTEM VALUE
VALUES
    -- Order 2 fully shipped
    (
        1,
        '60000000-0000-0000-0000-000000000001',
        3,
        '20000000-0000-0000-0000-000000000001',
        NULL,
        100
    ),
    (
        2,
        '60000000-0000-0000-0000-000000000001',
        4,
        '20000000-0000-0000-0000-000000000002',
        NULL,
        50
    ),

    -- Order 4 partially shipped
    (
        3,
        '60000000-0000-0000-0000-000000000002',
        6,
        '20000000-0000-0000-0000-000000000013',
        4,
        150
    );


-- ============================================================
-- 27. AUDIT LOGS
-- ============================================================

INSERT INTO audit_logs (
    user_id,
    organization_id,
    entity_type,
    entity_id,
    action,
    old_values,
    new_values
)
OVERRIDING SYSTEM VALUE
VALUES
    (
        '00000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000001',
        'purchase_order',
        '30000000-0000-0000-0000-000000000001',
        'STATUS_CHANGED',
        '{"status": "CONFIRMED"}',
        '{"status": "PARTIALLY_RECEIVED"}'
    ),
    (
        '00000000-0000-0000-0000-000000000004',
        '10000000-0000-0000-0000-000000000001',
        'pick_task',
        '1',
        'COMPLETED',
        '{"status": "IN_PROGRESS", "quantity_picked": 0}',
        '{"status": "COMPLETED", "quantity_picked": 100}'
    ),
    (
        '00000000-0000-0000-0000-000000000011',
        '10000000-0000-0000-0000-000000000002',
        'sales_order',
        '50000000-0000-0000-0000-000000000003',
        'CREATED',
        NULL,
        '{"status": "CONFIRMED"}'
    ),
    (
        '00000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'user',
        '00000000-0000-0000-0000-000000000004',
        'ROLE_ASSIGNED',
        NULL,
        '{"role": "Picker"}'
    );


-- ============================================================
-- 28. RESET SEQUENCES
-- ============================================================
--
-- Because many seed rows use explicit IDs, make sure future
-- generated IDs don't collide with them.
--
-- The following SELECTs advance the sequences to at least the
-- highest seeded value.
-- ============================================================

SELECT setval(
    pg_get_serial_sequence('warehouses', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM warehouses), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('locations', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM locations), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('product_categories', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM product_categories), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('inventory_lots', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM inventory_lots), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('stock_balances', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM stock_balances), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('inventory_transactions', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM inventory_transactions), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('inventory_transaction_lines', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM inventory_transaction_lines), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('inventory_reservations', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM inventory_reservations), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('pick_tasks', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM pick_tasks), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('shipment_items', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM shipment_items), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('po_line_items', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM po_line_items), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('receipt_items', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM receipt_items), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('order_line_items', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM order_line_items), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('permissions', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM permissions), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('roles', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM roles), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('audit_logs', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM audit_logs), 1),
        1
    )
);

SELECT setval(
    pg_get_serial_sequence('error_logs', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM error_logs), 1),
        1
    )
);


-- ============================================================
-- 29. BASIC DATA-INTEGRITY CHECKS
-- ============================================================

DO $$
DECLARE
    expected_count INTEGER;
BEGIN

    SELECT COUNT(*)
    INTO expected_count
    FROM users;

    IF expected_count <> 10 THEN
        RAISE EXCEPTION
            'Seed validation failed: expected 10 users, got %',
            expected_count;
    END IF;


    SELECT COUNT(*)
    INTO expected_count
    FROM organizations;

    IF expected_count <> 5 THEN
        RAISE EXCEPTION
            'Seed validation failed: expected 5 organizations, got %',
            expected_count;
    END IF;


    SELECT COUNT(*)
    INTO expected_count
    FROM products;

    IF expected_count <> 6 THEN
        RAISE EXCEPTION
            'Seed validation failed: expected 6 products, got %',
            expected_count;
    END IF;


    SELECT COUNT(*)
    INTO expected_count
    FROM warehouses;

    IF expected_count <> 2 THEN
        RAISE EXCEPTION
            'Seed validation failed: expected 2 warehouses, got %',
            expected_count;
    END IF;


    SELECT COUNT(*)
    INTO expected_count
    FROM sales_orders;

    IF expected_count <> 4 THEN
        RAISE EXCEPTION
            'Seed validation failed: expected 4 sales orders, got %',
            expected_count;
    END IF;


    SELECT COUNT(*)
    INTO expected_count
    FROM purchase_orders;

    IF expected_count <> 3 THEN
        RAISE EXCEPTION
            'Seed validation failed: expected 3 purchase orders, got %',
            expected_count;
    END IF;

END $$;


COMMIT;
