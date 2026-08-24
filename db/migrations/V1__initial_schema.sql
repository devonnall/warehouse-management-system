START TRANSACTION;

CREATE TABLE "sessions" (
    "sid" VARCHAR NOT NULL COLLATE "default",
    "sess" JSON NOT NULL,
    "expire" TIMESTAMP(6) NOT NULL
)
WITH (OIDS=FALSE);

CREATE TABLE error_logs (
    error_id INT GENERATED ALWAYS AS IDENTITY,
    error_type VARCHAR(255),
    func VARCHAR(255),
    arguments VARCHAR(255),
    error VARCHAR(255)
);

CREATE TABLE users (
    user_id UUID DEFAULT uuidv7(),
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    first_name VARCHAR(100),
    last_name VARCHAR(100)
);

CREATE TABLE admins (
    admin_id UUID,
    became_admin_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clients (
    client_id UUID DEFAULT uuidv7(),
    rep_id UUID NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20),
    billing_address VARCHAR(255) NOT NULL
);

CREATE TABLE vendors (
    vendor_id UUID DEFAULT uuidv7(),
    rep_id UUID NOT NULL,
    vendor_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20)
);

CREATE TABLE product_categories (
    category_id INT GENERATED ALWAYS AS IDENTITY,
    category_name VARCHAR(255) NOT NULL,
    parent_category_id INT
);

CREATE TABLE products (
    product_id UUID DEFAULT uuidv7(),
    client_id UUID NOT NULL,
    category_id INT,
    sku VARCHAR(255) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    unit_weight_kg FLOAT,
    dimensions_cm VARCHAR(50),
    reorder_threshold INT,
    is_perishable BOOLEAN DEFAULT FALSE
);

CREATE TABLE locations (
    location_id INT GENERATED ALWAYS AS IDENTITY,
    zone VARCHAR(50) NOT NULL,
    aisle VARCHAR(50) NOT NULL,
    rack VARCHAR(50) NOT NULL,
    shelf VARCHAR(50) NOT NULL,
    bin VARCHAR(50) NOT NULL,
    max_weight_capacity_kg FLOAT NOT NULL,
    is_occupied BOOLEAN DEFAULT FALSE
);

CREATE TABLE inventory_lots (
    lot_id INT GENERATED ALWAYS AS IDENTITY,
    product_id UUID NOT NULL,
    lot_number VARCHAR(255) NOT NULL,
    manufacture_date TIMESTAMP NOT NULL,
    expiration_date TIMESTAMP
);

CREATE TABLE stock_balances (
    stock_id INT GENERATED ALWAYS AS IDENTITY,
    product_id UUID NOT NULL,
    location_id INT NOT NULL,
    lot_id INT NOT NULL,
    quantity_on_hand INT,
    quantity_reserved INT
);

CREATE TABLE purchase_orders (
    po_id UUID DEFAULT uuidv7(),
    client_id UUID NOT NULL,
    vendor_id UUID NOT NULL,
    status VARCHAR(50),
    expected_delivery_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE po_line_items (
    po_item_id INT GENERATED ALWAYS AS IDENTITY,
    po_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity_expected INT NOT NULL,
    quantity_received INT
);

CREATE TABLE sales_orders (
    order_id UUID DEFAULT uuidv7(),
    client_id UUID NOT NULL,
    order_type VARCHAR(100),
    order_status VARCHAR(100),
    shipping_address VARCHAR(255),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_line_items (
    order_item_id INT GENERATED ALWAYS AS IDENTITY,
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity_ordered INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE shipments (
    shipment_id UUID DEFAULT uuidv7(),
    order_id UUID NOT NULL,
    carrier_name VARCHAR(255) NOT NULL,
    tracking_number VARCHAR(255) NOT NULL,
    shipping_cost DECIMAL(10, 2) NOT NULL,
    shipped_at TIMESTAMP
);

CREATE TABLE stock_movements (
    movement_id INT GENERATED ALWAYS AS IDENTITY,
    product_id UUID NOT NULL,
    source_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    quantity INT NOT NULL,
    movement_type VARCHAR(100),
    reference_type VARCHAR(100) ,
    movement_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
