START TRANSACTION;

ALTER TABLE "sessions" ADD CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE error_logs
ADD CONSTRAINT pk_error_logs PRIMARY KEY (error_id);

ALTER TABLE users
ADD CONSTRAINT pk_users PRIMARY KEY (user_id),
ADD CONSTRAINT chk_users_updated_at CHECK (updated_at >= created_at);

ALTER TABLE admins
ADD CONSTRAINT pk_admins PRIMARY KEY (admin_id),
ADD CONSTRAINT fk_admins_users FOREIGN KEY (admin_id)
    REFERENCES users(user_id);

ALTER TABLE clients
ADD CONSTRAINT pk_clients PRIMARY KEY (client_id),
ADD CONSTRAINT fk_clients_users FOREIGN KEY (rep_id)
    REFERENCES users(user_id);

ALTER TABLE vendors
ADD CONSTRAINT pk_vendors PRIMARY KEY (vendor_id),
ADD CONSTRAINT fk_vendors_users FOREIGN KEY (rep_id)
    REFERENCES users(user_id);

ALTER TABLE product_categories
ADD CONSTRAINT pk_product_categories PRIMARY KEY (category_id),
ADD CONSTRAINT fk_product_categories_self FOREIGN KEY (parent_category_id)
    REFERENCES product_categories(category_id);

ALTER TABLE products
ADD CONSTRAINT pk_products PRIMARY KEY (product_id),
ADD CONSTRAINT fk_products_clients FOREIGN KEY (client_id)
    REFERENCES clients(client_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_products_categories FOREIGN KEY (category_id)
    REFERENCES product_categories(category_id) ON DELETE SET NULL,
ADD CONSTRAINT chk_products_unit_weight_kg CHECK (unit_weight_kg >= 0),
ADD CONSTRAINT chk_products_reorder_threshold CHECK (reorder_threshold >= 0);

ALTER TABLE locations
ADD CONSTRAINT pk_locations PRIMARY KEY (location_id),
ADD CONSTRAINT chk_locations_max_weight_capacity_kg CHECK (max_weight_capacity_kg >= 0);

ALTER TABLE inventory_lots
ADD CONSTRAINT pk_inventory_lots PRIMARY KEY (lot_id),
ADD CONSTRAINT fk_inventory_lots_products FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE RESTRICT,
ADD CONSTRAINT chk_inventory_lots_expiration_date CHECK (expiration_date >= manufacture_date);

ALTER TABLE stock_balances
ADD CONSTRAINT pk_stock_balances PRIMARY KEY (stock_id),
ADD CONSTRAINT fk_stock_balances_products FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE RESTRICT,
ADD CONSTRAINT fk_stock_balances_locations FOREIGN KEY (location_id)
    REFERENCES locations(location_id) ON DELETE RESTRICT,
ADD CONSTRAINT fk_stock_balances_inventory_lots FOREIGN KEY (lot_id)
    REFERENCES inventory_lots(lot_id) ON DELETE RESTRICT,
ADD CONSTRAINT chk_stock_balances_quantity_on_hand CHECK (quantity_on_hand >= 0),
ADD CONSTRAINT chk_stock_balances_quantity_reserved CHECK (quantity_reserved >= 0);

ALTER TABLE purchase_orders
ADD CONSTRAINT pk_purchase_orders PRIMARY KEY (po_id),
ADD CONSTRAINT fk_purchase_orders_clients FOREIGN KEY (client_id)
    REFERENCES clients(client_id) ON DELETE RESTRICT,
ADD CONSTRAINT fk_purchase_orders_vendors FOREIGN KEY (vendor_id)
    REFERENCES vendors(vendor_id) ON DELETE RESTRICT,
ADD CONSTRAINT chk_purchase_orders_expected_delivery_date CHECK (expected_delivery_date >= created_at);

ALTER TABLE po_line_items
ADD CONSTRAINT pk_po_line_items PRIMARY KEY (po_item_id),
ADD CONSTRAINT fk_po_line_items_purchase_orders FOREIGN KEY (po_id)
    REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_po_line_items_products FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE RESTRICT,
ADD CONSTRAINT chk_po_line_items_quantity_expected CHECK (quantity_expected >= 0);

ALTER TABLE sales_orders
ADD CONSTRAINT pk_sales_orders PRIMARY KEY (order_id),
ADD CONSTRAINT fk_sales_orders_clients FOREIGN KEY (client_id)
    REFERENCES clients(client_id) ON DELETE RESTRICT;

ALTER TABLE order_line_items
ADD CONSTRAINT pk_order_line_items PRIMARY KEY (order_item_id),
ADD CONSTRAINT fk_order_line_items_sales_orders FOREIGN KEY (order_id)
    REFERENCES sales_orders(order_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_order_line_items_products FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE RESTRICT,
ADD CONSTRAINT chk_order_line_items_quantity_ordered CHECK (quantity_ordered >= 0),
ADD CONSTRAINT chk_order_line_items_unit_price CHECK (unit_price >= 0);

ALTER TABLE shipments
ADD CONSTRAINT pk_shipments PRIMARY KEY (shipment_id),
ADD CONSTRAINT fk_shipments_sales_orders FOREIGN KEY (order_id)
    REFERENCES sales_orders(order_id),
ADD CONSTRAINT chk_shipments_shipping_cost CHECK (shipping_cost >= 0);

ALTER TABLE stock_movements
ADD CONSTRAINT pk_stock_movements PRIMARY KEY (movement_id),
ADD CONSTRAINT fk_stock_movements_products FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE RESTRICT,
ADD CONSTRAINT fk_stock_movements_locations_source FOREIGN KEY (source_location_id)
    REFERENCES locations(location_id) ON DELETE RESTRICT,
ADD CONSTRAINT fk_stock_movements_locations_destination FOREIGN KEY (destination_location_id)
    REFERENCES locations(location_id) ON DELETE RESTRICT,
ADD CONSTRAINT chk_stock_movements_quantity CHECK (quantity >= 0);

COMMIT;
