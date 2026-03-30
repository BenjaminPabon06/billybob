-- MS3083 Assignment 3

-- Name: [Benjamin Pabon]   Date: [3/29/26]

-- SECTION 1: Schema
DROP SCHEMA IF EXISTS Ben_canes CASCADE;
CREATE SCHEMA Ben_canes;

-- SECTION 2: Table Creation
CREATE TABLE ben_canes.ingredient (
    ingredient_id     INTEGER PRIMARY KEY,
    ingredient_name   VARCHAR(100) NOT NULL,
    category          VARCHAR(50) NOT NULL,
    unit_of_measure   VARCHAR(50) NOT NULL,
    cost_per_unit     NUMERIC(10,2) NOT NULL,
    reorder_level     INTEGER NOT NULL
); 

CREATE TABLE ben_canes.location (
    location_id       INTEGER PRIMARY KEY,
    location_name     VARCHAR(100) NOT NULL,
    storage_type      VARCHAR(50) NOT NULL,
    temperature_zone  VARCHAR(50) NOT NULL,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE ben_canes.inventory (
    inventory_id      INTEGER PRIMARY KEY,
    ingredient_id     INTEGER NOT NULL REFERENCES ben_canes.ingredient(ingredient_id),
    location_id       INTEGER NOT NULL REFERENCES ben_canes.location(location_id),
    quantity_on_hand  INTEGER NOT NULL,
    reorder_point     INTEGER NOT NULL,
    max_stock_level   INTEGER NOT NULL,
    last_updated      DATE NOT NULL
);

CREATE TABLE ben_canes.supplier (
    supplier_id      INTEGER PRIMARY KEY,
    supplier_name    VARCHAR(100) NOT NULL,
    contact_name     VARCHAR(100) NOT NULL,
    phone_number     VARCHAR(20) NOT NULL,
    lead_time_days   INTEGER NOT NULL,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE ben_canes.purchase_order (
    purchase_order_id        INTEGER PRIMARY KEY,
    supplier_id              INTEGER NOT NULL REFERENCES ben_canes.supplier(supplier_id),
    ingredient_id            INTEGER NOT NULL REFERENCES ben_canes.ingredient(ingredient_id),
    quantity_ordered         INTEGER NOT NULL,
    order_date               DATE NOT NULL,
    estimated_delivery_date  DATE NOT NULL,
    total_cost               NUMERIC(10,2) NOT NULL,
    order_status             VARCHAR(50) NOT NULL
);

-- SECTION 3: Data Insertion
COPY ben_canes.ingredient 
(ingredient_id, ingredient_name, category, unit_of_measure, cost_per_unit, reorder_level)
FROM '/workspaces/billybob/data/p_canes/ingredients.csv' WITH (FORMAT csv, HEADER true);

COPY ben_canes.location 
(location_id, location_name, storage_type, temperature_zone, is_active)
FROM '/workspaces/billybob/data/p_canes/locations.csv' WITH (FORMAT csv, HEADER true);

COPY ben_canes.inventory
(inventory_id, ingredient_id, location_id, quantity_on_hand, reorder_point, max_stock_level, last_updated)
FROM '/workspaces/billybob/data/p_canes/inventory.csv' WITH (FORMAT csv, HEADER true);

COPY ben_canes.supplier 
(supplier_id, supplier_name, contact_name, phone_number, lead_time_days, is_active) 
FROM '/workspaces/billybob/data/p_canes/supplier.csv' WITH (FORMAT csv, HEADER true);

COPY ben_canes.purchase_order 
(purchase_order_id, supplier_id, ingredient_id, quantity_ordered, order_date, estimated_delivery_date, total_cost, order_status)
FROM '/workspaces/billybob/data/p_canes/purchase_order.csv' WITH (FORMAT csv, HEADER true);

-- SECTION 4: Queries
-- VERIFY: Row Counts
SELECT 'ingredient' AS table_name, COUNT(*) AS row_count FROM ben_canes.ingredient;
SELECT 'location' AS table_name, COUNT(*) AS row_count FROM ben_canes.location;
SELECT 'inventory' AS table_name, COUNT(*) AS row_count FROM ben_canes.inventory;
SELECT 'supplier' AS table_name, COUNT(*) AS row_count FROM ben_canes.supplier;
SELECT 'purchase_order' AS table_name, COUNT(*) AS row_count FROM ben_canes.purchase_order;

-- VERIFY: Full ingredient list
SELECT * FROM ben_canes.ingredient;

-- VERIFY: Inventory with ingredient names
SELECT i.inventory_id, i.quantity_on_hand, i.last_updated, ing.ingredient_name
FROM ben_canes.inventory i
JOIN ben_canes.ingredient ing ON i.ingredient_id = ing.ingredient_id;

-- VERIFY: Inventory with location names
SELECT i.inventory_id, i.quantity_on_hand, i.last_updated, l.location_name
FROM ben_canes.inventory i
JOIN ben_canes.location l ON i.location_id = l.location_id;

-- VERIFY: Purchase orders with supplier and ingredient names
SELECT purchase_order_id, quantity_ordered, order_date, estimated_delivery_date, total_cost, order_status, s.supplier_name, ing.ingredient_name
FROM ben_canes.purchase_order po
JOIN ben_canes.supplier s ON po.supplier_id = s.supplier_id
JOIN ben_canes.ingredient ing ON po.ingredient_id = ing.ingredient_id;

-- VERIFY: Foreign key enforcement
INSERT INTO ben_canes.inventory (inventory_id, ingredient_id, location_id, quantity_on_hand, reorder_point, max_stock_level, last_updated)
VALUES (999, 999, 999, 100, 10, 200, CURRENT_DATE);
-- This should fail due to foreign key constraints on ingredient_id and location_id.

-- SECTION 5: REFLECTION


/*

==========================================================
REFLECTION  —  MS3083 Assignment 3

Name: [Benjamin Pabon]   Date: [3/29/26]
==========================================================

Q1 — Data Type Decision:

Choosing the data type for phone numbers in the supplier table was one moment that required real consideration. I had to choose between storing them as numeric types, which seems intuitive, or as text. Numeric types would strip leading zeros and prevent formatting like dashes or parentheses, so I ultimately chose VARCHAR to preserve the full structure of the number. This choice keeps the data flexible and avoids treating phone numbers like values you would ever calculate with.


Q2 — INVENTORY Foreign Keys Explained:

Each foreign key in the INVENTORY table acts like a safeguard against bad data. The link to INGREDIENT makes sure every inventory record refers to a real ingredient, preventing the system from tracking stock for items that don’t exist. The link to LOCATION ensures inventory is only assigned to valid storage areas, avoiding mistakes like placing quantities in a location that isn’t real or active.


Q3 — How the Three-Table JOIN Works:

First, one table (like PURCHASE_ORDER) is matched to a second table (like SUPPLIER) using the shared key (supplier_id) so each order is paired with the correct supplier. Then that result is matched to a third table (like INGREDIENT) using ingredient_id so each row now carries order details, supplier info, and ingredient info together. The order of the JOINs usually doesn’t matter logically as long as the join conditions are correct, because the database engine figures out the best way to combine them behind the scenes.


Q4 — Scaling to New Locations:

Adding five new restaurant locations would only require inserting five new rows into the LOCATION table, because each store is represented as a location record. No new columns are needed anywhere—the existing design already supports unlimited locations, and other tables will simply reference the new location IDs when needed. With five separate Excel files, you’d risk broken formulas, mismatched IDs, and inconsistent updates because nothing enforces relationships across sheets.

*/