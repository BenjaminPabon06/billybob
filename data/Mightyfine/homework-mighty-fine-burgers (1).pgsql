-- ============================================================================
-- HOMEWORK: Mighty Fine Burgers — Build & Analyze a Restaurant Database
-- ============================================================================
--
-- Student Name: Benjamin Pabon
-- Date:         4/12/26
-- Course:       MS 3083 — Data Management
--
-- ============================================================================
-- ABOUT MIGHTY FINE BURGERS
-- ============================================================================
-- Mighty Fine Burgers, Fries & Shakes is a popular Austin, Texas restaurant
-- known for hand-crafted burgers made from 100% natural Angus beef,
-- hand-cut fries, and hand-spun shakes.
--
-- Website: https://www.mightyfineburgers.com/
--
-- In this homework you will build a full relational database for Mighty Fine
-- from scratch — the same way we built the Hotdog Stand database in class.
-- The CSV data files are provided in:
--
--     data/mightyfine/
--         owners.csv
--         vendors.csv
--         ingredients.csv
--         inventory.csv
--         menu_items.csv
--         menu_item_ingredients.csv    (the bridge table!)
--         sales.csv
--         sale_items.csv
--
-- ============================================================================
-- HOW TO COMPLETE THIS HOMEWORK
-- ============================================================================
-- 1. Read each task's REQUIREMENTS carefully.
-- 2. Write your SQL where it says:  -- YOUR CODE HERE
-- 3. Highlight your code and press Ctrl+E (or F5) to run it.
-- 4. Verify your results match the expected output described.
-- 5. Work through the tasks IN ORDER — later tasks depend on earlier ones.
--
-- GRADING:
--   Part 1 (Schema & Tables)      — 20 pts
--   Part 2 (Load Data)            — 10 pts
--   Part 3 (Basic Queries)        — 15 pts
--   Part 4 (Aliases & Joins)      — 20 pts
--   Part 5 (Bridge Table)         — 15 pts
--   Part 6 (Math & Business)      — 20 pts
--   TOTAL                         — 100 pts
-- ============================================================================


-- ############################################################################
--
--     PART 1: CREATE THE SCHEMA AND TABLES  (20 pts)
--
-- ############################################################################


-- ============================================================================
-- TASK 1.1: CREATE THE SCHEMA (2 pts)
-- ============================================================================
-- REQUIREMENTS:
--   - Drop the schema "mightyfine" if it already exists (use CASCADE).
--   - Create a new schema called "mightyfine".
-- ============================================================================

DROP SCHEMA IF EXISTS mightyfine CASCADE;
CREATE SCHEMA mightyfine;

-- ============================================================================
-- TASK 1.2: CREATE THE OWNERS TABLE (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.owners with these columns:
--     owner_id    — auto-incrementing integer, primary key
--     first_name  — text up to 50 characters, NOT NULL
--     last_name   — text up to 50 characters, NOT NULL
--     email       — text up to 100 characters
--     phone       — text up to 20 characters
--     created_at  — timestamp, default to CURRENT_TIMESTAMP
--
-- HINT: Look at how hotdog.owners was created in the lesson.
-- ============================================================================

CREATE TABLE mightyfine.owners (
    owner_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TASK 1.3: CREATE THE VENDORS TABLE (2 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.vendors with these columns:
--     vendor_id    — auto-incrementing integer, primary key
--     vendor_name  — text up to 100 characters, NOT NULL
--     contact_name — text up to 100 characters
--     phone        — text up to 20 characters
--     email        — text up to 100 characters
--     address      — text up to 200 characters
--     created_at   — timestamp, default to CURRENT_TIMESTAMP
-- ============================================================================

CREATE TABLE mightyfine.vendors (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TASK 1.4: CREATE THE INGREDIENTS TABLE (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.ingredients with these columns:
--     ingredient_id   — auto-incrementing integer, primary key
--     ingredient_name — text up to 100 characters, NOT NULL
--     unit            — text up to 20 characters, NOT NULL
--     cost_per_unit   — numeric(8,2), NOT NULL
--     vendor_id       — integer, FOREIGN KEY referencing mightyfine.vendors
-- ============================================================================

CREATE TABLE mightyfine.ingredients (
    ingredient_id SERIAL PRIMARY KEY,
    ingredient_name VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    cost_per_unit NUMERIC(8,2) NOT NULL,
    vendor_id INTEGER REFERENCES mightyfine.vendors(vendor_id)
);

-- ============================================================================
-- TASK 1.5: CREATE THE INVENTORY TABLE (2 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.inventory with these columns:
--     inventory_id   — auto-incrementing integer, primary key
--     ingredient_id  — integer, NOT NULL, FOREIGN KEY → mightyfine.ingredients
--     quantity        — numeric(10,2), NOT NULL, default 0
--     reorder_level   — numeric(10,2), NOT NULL, default 10
--     last_restocked  — date
--     updated_at      — timestamp, default to CURRENT_TIMESTAMP
-- ============================================================================

CREATE TABLE mightyfine.inventory (
    inventory_id SERIAL PRIMARY KEY,
    ingredient_id INTEGER NOT NULL REFERENCES mightyfine.ingredients(ingredient_id),
    quantity NUMERIC(10,2) NOT NULL DEFAULT 0,
    reorder_level NUMERIC(10,2) NOT NULL DEFAULT 10,
    last_restocked DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TASK 1.6: CREATE THE MENU_ITEMS TABLE (2 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.menu_items with these columns:
--     menu_item_id  — auto-incrementing integer, primary key
--     item_name     — text up to 100 characters, NOT NULL
--     description   — text up to 255 characters
--     price         — numeric(6,2), NOT NULL
--     is_available  — boolean, default TRUE
-- ============================================================================

CREATE TABLE mightyfine.menu_items (
    menu_item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    price NUMERIC(6,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

-- ============================================================================
-- TASK 1.7: CREATE THE MENU_ITEM_INGREDIENTS TABLE (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   This is the BRIDGE TABLE that connects menu items to ingredients.
--   Create a table called mightyfine.menu_item_ingredients with:
--     menu_item_ingredient_id — auto-incrementing integer, primary key
--     menu_item_id   — integer, NOT NULL, FOREIGN KEY → mightyfine.menu_items
--     ingredient_id  — integer, NOT NULL, FOREIGN KEY → mightyfine.ingredients
--     quantity_used  — numeric(8,2), NOT NULL
--
-- WHY IS THIS TABLE NEEDED?
--   One menu item uses MANY ingredients.
--   One ingredient is used in MANY menu items.
--   This many-to-many relationship requires a bridge table in the middle.
-- ============================================================================

CREATE TABLE mightyfine.menu_item_ingredients (
    menu_item_ingredient_id SERIAL PRIMARY KEY,
    menu_item_id INTEGER NOT NULL REFERENCES mightyfine.menu_items(menu_item_id),
    ingredient_id INTEGER NOT NULL REFERENCES mightyfine.ingredients(ingredient_id),
    quantity_used NUMERIC(8,2) NOT NULL
);

-- ============================================================================
-- TASK 1.8: CREATE THE SALES TABLE (1 pt)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.sales with these columns:
--     sale_id      — auto-incrementing integer, primary key
--     sale_date    — timestamp, NOT NULL, default CURRENT_TIMESTAMP
--     owner_id     — integer, FOREIGN KEY → mightyfine.owners
--     total_amount — numeric(8,2)
--     payment_type — text up to 20 characters, default 'cash'
-- ============================================================================

CREATE TABLE mightyfine.sales (
    sale_id SERIAL PRIMARY KEY,
    sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    owner_id INTEGER REFERENCES mightyfine.owners(owner_id),
    total_amount NUMERIC(8,2),
    payment_type VARCHAR(20) DEFAULT 'cash'
);

-- ============================================================================
-- TASK 1.9: CREATE THE SALE_ITEMS TABLE (2 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Create a table called mightyfine.sale_items with these columns:
--     sale_item_id  — auto-incrementing integer, primary key
--     sale_id       — integer, NOT NULL, FOREIGN KEY → mightyfine.sales
--     menu_item_id  — integer, NOT NULL, FOREIGN KEY → mightyfine.menu_items
--     quantity      — integer, NOT NULL, default 1
--     line_total    — numeric(8,2), NOT NULL
-- ============================================================================

CREATE TABLE mightyfine.sale_items (
    sale_item_id SERIAL PRIMARY KEY,
    sale_id INTEGER NOT NULL REFERENCES mightyfine.sales(sale_id),
    menu_item_id INTEGER NOT NULL REFERENCES mightyfine.menu_items(menu_item_id),
    quantity INTEGER NOT NULL DEFAULT 1,
    line_total NUMERIC(8,2) NOT NULL
);

-- ############################################################################
--
--     PART 2: LOAD DATA FROM CSV FILES  (10 pts)
--
-- ############################################################################


-- ============================================================================
-- TASK 2.1: LOAD ALL 8 TABLES FROM CSV (8 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Load data into each table using the COPY command.
--   The CSV files are located at:
--     /workspaces/billybob/data/Mightyfine/
--
--   IMPORTANT: Load in this order (parent tables first!):
--     1. owners
--     2. vendors
--     3. ingredients      (needs vendors to exist first)
--     4. inventory        (needs ingredients to exist first)
--     5. menu_items
--     6. menu_item_ingredients  (needs menu_items AND ingredients)
--     7. sales            (needs owners to exist first)
--     8. sale_items       (needs sales AND menu_items)
--
--
-- If you get a "must be superuser" error, run this in the Terminal:
--   psql -U jovyan -d postgres -c "ALTER ROLE student WITH SUPERUSER;"
-- ============================================================================

COPY mightyfine.owners (owner_id, first_name, last_name, email, phone) FROM '/workspaces/billybob/data/Mightyfine/owners (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.vendors (vendor_id, vendor_name, contact_name, phone, email, address) FROM '/workspaces/billybob/data/Mightyfine/vendors (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.ingredients (ingredient_id, ingredient_name, unit, cost_per_unit, vendor_id) FROM '/workspaces/billybob/data/Mightyfine/ingredients (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.inventory (inventory_id, ingredient_id, quantity, reorder_level, last_restocked) FROM '/workspaces/billybob/data/Mightyfine/inventory (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.menu_items (menu_item_id, item_name, description, price, is_available) FROM '/workspaces/billybob/data/Mightyfine/menu_items (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.menu_item_ingredients (menu_item_ingredient_id, menu_item_id, ingredient_id, quantity_used) FROM '/workspaces/billybob/data/Mightyfine/menu_item_ingredients (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.sales (sale_id, sale_date, owner_id, total_amount, payment_type) FROM '/workspaces/billybob/data/Mightyfine/sales (2).csv' WITH (FORMAT csv, HEADER true);
COPY mightyfine.sale_items (sale_item_id, sale_id, menu_item_id, quantity, line_total) FROM '/workspaces/billybob/data/Mightyfine/sale_items (2).csv' WITH (FORMAT csv, HEADER true);

-- ============================================================================
-- TASK 2.2: RESET THE SEQUENCES (1 pt)
-- ============================================================================
-- REQUIREMENTS:
--   After loading CSV data, the auto-increment sequences are out of sync.
--   Reset each sequence so future INSERTs get the correct next ID.
--

-- ============================================================================

SELECT setval('mightyfine.owners_owner_id_seq', (SELECT MAX(owner_id) FROM mightyfine.owners));
SELECT setval('mightyfine.vendors_vendor_id_seq', (SELECT MAX(vendor_id) FROM mightyfine.vendors));
SELECT setval('mightyfine.ingredients_ingredient_id_seq', (SELECT MAX(ingredient_id) FROM mightyfine.ingredients));
SELECT setval('mightyfine.inventory_inventory_id_seq', (SELECT MAX(inventory_id) FROM mightyfine.inventory));
SELECT setval('mightyfine.menu_items_menu_item_id_seq', (SELECT MAX(menu_item_id) FROM mightyfine.menu_items));
SELECT setval('mightyfine.menu_item_ingredients_menu_item_ingredient_id_seq', (SELECT MAX(menu_item_ingredient_id) FROM mightyfine.menu_item_ingredients));
SELECT setval('mightyfine.sales_sale_id_seq', (SELECT MAX(sale_id) FROM mightyfine.sales));
SELECT setval('mightyfine.sale_items_sale_item_id_seq', (SELECT MAX(sale_item_id) FROM mightyfine.sale_items));

-- ============================================================================
-- TASK 2.3: VERIFY THE DATA (1 pt)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows the row count for EVERY table in one result.
--   Use UNION ALL to combine the counts.
--   Your output should have two columns: table_name and row_count.
--
-- EXPECTED ROW COUNTS:
--   owners                  → 3
--   vendors                 → 6
--   ingredients             → 24
--   inventory               → 24
--   menu_items              → 11
--   menu_item_ingredients   → 49
--   sales                   → 25
--   sale_items              → 62
-- ============================================================================

SELECT 'owners' AS table_name, COUNT(*) AS row_count FROM mightyfine.owners
UNION ALL
SELECT 'vendors', COUNT(*) FROM mightyfine.vendors
UNION ALL
SELECT 'ingredients', COUNT(*) FROM mightyfine.ingredients
UNION ALL
SELECT 'inventory', COUNT(*) FROM mightyfine.inventory
UNION ALL
SELECT 'menu_items', COUNT(*) FROM mightyfine.menu_items
UNION ALL
SELECT 'menu_item_ingredients', COUNT(*) FROM mightyfine.menu_item_ingredients
UNION ALL
SELECT 'sales', COUNT(*) FROM mightyfine.sales
UNION ALL
SELECT 'sale_items', COUNT(*) FROM mightyfine.sale_items;

-- ############################################################################
--
--     PART 3: BASIC QUERIES — SELECT, WHERE, ORDER BY  (15 pts)
--
-- ############################################################################


-- ============================================================================
-- TASK 3.1: VIEW THE FULL MENU (2 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows ALL columns from the menu_items table.
--   Order by price from lowest to highest.
-- ============================================================================

SELECT * FROM mightyfine.menu_items
ORDER BY price ASC;

-- ============================================================================
-- TASK 3.2: EXPENSIVE ITEMS ONLY (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows only the item_name and price
--   for menu items that cost MORE than $9.00.
--   Order by price descending (most expensive first).
-- ============================================================================

SELECT item_name, price FROM mightyfine.menu_items
WHERE price > 9.00
ORDER BY price DESC;

-- ============================================================================
-- TASK 3.3: CARD SALES (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows sale_id, sale_date, and total_amount
--   for sales where payment_type is 'card'.
--   Order by total_amount descending.
--   Show only the top 5 results.
-- ============================================================================

SELECT sale_id, sale_date, total_amount FROM mightyfine.sales
WHERE payment_type = 'card'
ORDER BY total_amount DESC
LIMIT 5;

-- ============================================================================
-- TASK 3.4: INGREDIENT SEARCH (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that finds all ingredients supplied by vendor_id = 3.
--   Show ingredient_name, unit, and cost_per_unit.
--   Order by cost_per_unit descending.
-- ============================================================================

SELECT ingredient_name, unit, cost_per_unit FROM mightyfine.ingredients
WHERE vendor_id = 3
ORDER BY cost_per_unit DESC;

-- ============================================================================
-- TASK 3.5: COUNT THE SALES PER PAYMENT TYPE (4 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows how many sales were made by each payment_type.
--   Show payment_type and a column called num_sales.
--   Order by num_sales descending.
--
-- HINT: You'll need GROUP BY.
-- ============================================================================

SELECT payment_type, COUNT(*) AS num_sales FROM mightyfine.sales
GROUP BY payment_type
ORDER BY num_sales DESC;

-- ############################################################################
--
--     PART 4: ALIASES & JOINS — COMBINING TABLES  (20 pts)
--
-- ############################################################################
--
-- REMINDER — STANDARD ALIASES FOR MIGHTY FINE:
--   mightyfine.owners                  → o
--   mightyfine.vendors                 → v
--   mightyfine.ingredients             → i
--   mightyfine.inventory               → inv
--   mightyfine.menu_items              → mi
--   mightyfine.menu_item_ingredients   → bridge  (or mii)
--   mightyfine.sales                   → s
--   mightyfine.sale_items              → si
-- ============================================================================


-- ============================================================================
-- TASK 4.1: INNER JOIN — SALES + OWNERS (4 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows each sale with the owner's full name.
--   Columns to display:
--     sale_id, sale_date, owner_name (first + last combined), total_amount, payment_type
--   Use table aliases: s for sales, o for owners.
--   Order by sale_id.
--   Show only the first 10 rows.
--
-- ============================================================================

SELECT s.sale_id, s.sale_date, CONCAT(o.first_name, ' ', o.last_name) AS owner_name, s.total_amount, s.payment_type
FROM mightyfine.sales s
JOIN mightyfine.owners o ON s.owner_id = o.owner_id
ORDER BY s.sale_id
LIMIT 10;

-- ============================================================================
-- TASK 4.2: INNER JOIN — SALE ITEMS + MENU ITEMS (4 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query showing what items were sold.
--   Columns: sale_id, item_name, menu price (aliased as menu_price),
--            quantity, line_total
--   Use aliases: si for sale_items, mi for menu_items.
--   Join on menu_item_id.
--   Order by sale_id, then sale_item_id.
--   Show the first 15 rows.
-- ============================================================================

SELECT si.sale_id, mi.item_name, mi.price AS menu_price, si.quantity, si.line_total
FROM mightyfine.sale_items si
JOIN mightyfine.menu_items mi ON si.menu_item_id = mi.menu_item_id
ORDER BY si.sale_id, si.sale_item_id
LIMIT 15;

-- ============================================================================
-- TASK 4.3: INNER JOIN — INGREDIENTS + VENDORS (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query showing which vendor supplies each ingredient.
--   Columns: ingredient_name, cost_per_unit, unit, vendor_name, contact_name
--   Use aliases: i for ingredients, v for vendors.
--   Order by vendor_name, then ingredient_name.
-- ============================================================================

SELECT i.ingredient_name, i.cost_per_unit, i.unit, v.vendor_name, v.contact_name
FROM mightyfine.ingredients i
JOIN mightyfine.vendors v ON i.vendor_id = v.vendor_id
ORDER BY v.vendor_name, i.ingredient_name;

-- ============================================================================
-- TASK 4.4: LEFT JOIN — ALL MENU ITEMS + SALES COUNT (5 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows EVERY menu item and how many times it was sold.
--   Items with zero sales should still appear (with a count of 0).
--   Columns: item_name, times_sold (use COUNT of sale_item_id)
--   Use aliases: mi for menu_items, si for sale_items.
--   Order by times_sold descending.
--
-- WHY LEFT JOIN?
--   If you use INNER JOIN, any menu item with zero sales will DISAPPEAR.
--   LEFT JOIN keeps ALL menu items even if they have no matching sale_items.
-- ============================================================================

SELECT mi.item_name, COUNT(si.sale_item_id) AS times_sold
FROM mightyfine.menu_items mi
LEFT JOIN mightyfine.sale_items si ON mi.menu_item_id = si.menu_item_id
GROUP BY mi.item_name
ORDER BY times_sold DESC;

-- ============================================================================
-- TASK 4.5: MULTI-TABLE JOIN — FULL SALES REPORT (4 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query joining 4 tables to build a full sales detail report.
--   Columns: sale_id, sale_date, owner_name (first + last),
--            item_name, quantity, line_total, payment_type
--   Tables to join:
--     sales (s) → owners (o)       ON owner_id
--     sales (s) → sale_items (si)  ON sale_id
--     sale_items (si) → menu_items (mi) ON menu_item_id
--   Order by sale_id, then sale_item_id.
--   Show the first 20 rows.
-- ============================================================================

SELECT s.sale_id, s.sale_date, CONCAT(o.first_name, ' ', o.last_name) AS owner_name, mi.item_name, si.quantity, si.line_total, s.payment_type
FROM mightyfine.sales s
JOIN mightyfine.owners o ON s.owner_id = o.owner_id
JOIN mightyfine.sale_items si ON s.sale_id = si.sale_id
JOIN mightyfine.menu_items mi ON si.menu_item_id = mi.menu_item_id
ORDER BY s.sale_id, si.sale_item_id
LIMIT 20;

-- ############################################################################
--
--     PART 5: BRIDGE TABLE QUERIES  (15 pts)
--
-- ############################################################################


-- ============================================================================
-- TASK 5.1: READ THE RECIPE — JOIN THROUGH THE BRIDGE (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows every menu item and its ingredients.
--   Columns: item_name, ingredient_name, quantity_used, unit
--   Join menu_item_ingredients (bridge) to BOTH menu_items AND ingredients.
--   Use aliases: bridge, mi, i.
--   Order by item_name, then ingredient_name.
-- ============================================================================

SELECT mi.item_name, i.ingredient_name, bridge.quantity_used, i.unit
FROM mightyfine.menu_item_ingredients bridge
JOIN mightyfine.menu_items mi ON bridge.menu_item_id = mi.menu_item_id
JOIN mightyfine.ingredients i ON bridge.ingredient_id = i.ingredient_id
ORDER BY mi.item_name, i.ingredient_name;

-- ============================================================================
-- TASK 5.2: WHAT'S IN THE DOUBLE MIGHTY BURGER? (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows ONLY the ingredients for the
--   "Double Mighty Burger".
--   Columns: ingredient_name, quantity_used, unit
--   Use the same three-table join as 5.1, but add a WHERE clause.
-- ============================================================================

SELECT i.ingredient_name, bridge.quantity_used, i.unit
FROM mightyfine.menu_item_ingredients bridge
JOIN mightyfine.menu_items mi ON bridge.menu_item_id = mi.menu_item_id
JOIN mightyfine.ingredients i ON bridge.ingredient_id = i.ingredient_id
WHERE mi.item_name = 'Double Mighty Burger'
ORDER BY i.ingredient_name;

-- ============================================================================
-- TASK 5.3: WHICH ITEMS USE BACON? (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that shows which menu items contain "Bacon Strip"
--   as an ingredient.
--   Columns: item_name, price
--   Filter WHERE ingredient_name = 'Bacon Strip'.
--   Order by item_name.
-- ============================================================================

SELECT mi.item_name, mi.price
FROM mightyfine.menu_item_ingredients bridge
JOIN mightyfine.menu_items mi ON bridge.menu_item_id = mi.menu_item_id
JOIN mightyfine.ingredients i ON bridge.ingredient_id = i.ingredient_id
WHERE i.ingredient_name = 'Bacon Strip'
ORDER BY mi.item_name;

-- ============================================================================
-- TASK 5.4: INGREDIENT POPULARITY (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that counts how many menu items each ingredient
--   appears in.
--   Columns: ingredient_name, used_in_how_many_items (use COUNT)
--   Join menu_item_ingredients (bridge) to ingredients.
--   GROUP BY ingredient_name.
--   Order by used_in_how_many_items descending.
-- ============================================================================

SELECT i.ingredient_name, COUNT(bridge.menu_item_id) AS used_in_how_many_items
FROM mightyfine.menu_item_ingredients bridge
JOIN mightyfine.ingredients i ON bridge.ingredient_id = i.ingredient_id
GROUP BY i.ingredient_name
ORDER BY used_in_how_many_items DESC;

-- ============================================================================
-- TASK 5.5: INGREDIENT COUNT PER MENU ITEM (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query that counts how many ingredients each menu item uses.
--   Columns: item_name, number_of_ingredients (use COUNT)
--   Join menu_item_ingredients (bridge) to menu_items.
--   GROUP BY item_name.
--   Order by number_of_ingredients descending.
-- ============================================================================

SELECT mi.item_name, COUNT(bridge.ingredient_id) AS number_of_ingredients
FROM mightyfine.menu_item_ingredients bridge
JOIN mightyfine.menu_items mi ON bridge.menu_item_id = mi.menu_item_id
GROUP BY mi.item_name
ORDER BY number_of_ingredients DESC;

-- ############################################################################
--
--     PART 6: MATH FUNCTIONS & BUSINESS CALCULATIONS  (20 pts)
--
-- ############################################################################


-- ============================================================================
-- TASK 6.1: BASIC AGGREGATES (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write ONE query (no GROUP BY) that shows:
--     total_revenue  — SUM of total_amount from sales
--     avg_sale       — AVG of total_amount, rounded to 2 decimals
--     total_sales    — COUNT of all rows in sales
--     cheapest_item  — MIN price from menu_items
--     priciest_item  — MAX price from menu_items
--
-- 
--       ...
-- ============================================================================

SELECT
    (SELECT SUM(total_amount) FROM mightyfine.sales) AS total_revenue,
    ROUND((SELECT AVG(total_amount) FROM mightyfine.sales), 2) AS avg_sale,
    (SELECT COUNT(*) FROM mightyfine.sales) AS total_sales,
    (SELECT MIN(price) FROM mightyfine.menu_items) AS cheapest_item,
    (SELECT MAX(price) FROM mightyfine.menu_items) AS priciest_item;

-- ============================================================================
-- TASK 6.2: REVENUE PER OWNER (4 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query showing each owner's total revenue and number of sales.
--   Columns: owner_name (first + last), number_of_sales, total_revenue
--   Use LEFT JOIN (in case an owner has no sales).
--   Use COALESCE to show 0 instead of NULL for owners with no sales.
--   Order by total_revenue descending.
-- ============================================================================

SELECT CONCAT(o.first_name, ' ', o.last_name) AS owner_name,
COUNT(s.sale_id) AS number_of_sales,
COALESCE(SUM(s.total_amount), 0) AS total_revenue
FROM mightyfine.owners o
LEFT JOIN mightyfine.sales s ON o.owner_id = s.owner_id
GROUP BY owner_name
ORDER BY total_revenue DESC;

-- ============================================================================
-- TASK 6.3: BEST-SELLING ITEMS BY QUANTITY (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query showing each menu item's total quantity sold and revenue.
--   Columns: item_name, total_qty_sold (SUM of quantity),
--            total_revenue (SUM of line_total)
--   Join sale_items to menu_items.
--   GROUP BY item_name.
--   Order by total_qty_sold descending.
-- ============================================================================

SELECT mi.item_name,
SUM(si.quantity) AS total_qty_sold,
SUM(si.line_total) AS total_revenue
FROM mightyfine.sale_items si
JOIN mightyfine.menu_items mi ON si.menu_item_id = mi.menu_item_id
GROUP BY mi.item_name
ORDER BY total_qty_sold DESC;

-- ============================================================================
-- TASK 6.4: INVENTORY VALUE (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Write a query showing the dollar value of each ingredient in stock.
--   Columns: ingredient_name, qty_on_hand, unit, cost_per_unit,
--            inventory_value (quantity × cost_per_unit, rounded to 2 decimals)
--   Join inventory (inv) to ingredients (ing).
--   Order by inventory_value descending.
--
-- THEN write a second query showing:
--   total_ingredients (COUNT) and total_inventory_value (SUM, rounded to 2).
-- ============================================================================

SELECT i.ingredient_name, inv.quantity AS qty_on_hand, i.unit, i.cost_per_unit,
ROUND(inv.quantity * i.cost_per_unit, 2) AS inventory_value
FROM mightyfine.inventory inv
JOIN mightyfine.ingredients i ON inv.ingredient_id = i.ingredient_id
ORDER BY inventory_value DESC;

-- ============================================================================
-- TASK 6.5: PROFIT PER MENU ITEM (4 pts)
-- ============================================================================
-- REQUIREMENTS:
--   Using the bridge table, calculate the total ingredient cost for each
--   menu item, then compute profit and profit margin.
--
--   Columns:
--     item_name
--     selling_price       — the menu item price
--     total_ingredient_cost — SUM(quantity_used × cost_per_unit), rounded to 2
--     profit              — selling_price − total_ingredient_cost, rounded to 2
--     profit_margin_pct   — (profit / selling_price) × 100, rounded to 1
--
--   Join: bridge → menu_items, bridge → ingredients
--   GROUP BY item_name, price
--   Order by profit_margin_pct descending.
--
-- THIS IS THE BIG ONE — it combines bridge tables, joins, aggregates,
-- and math all in one query. Refer to the hotdog lesson Report 4.
-- ============================================================================

SELECT mi.item_name, mi.price AS selling_price,
ROUND(SUM(bridge.quantity_used * i.cost_per_unit), 2) AS total_ingredient_cost,
ROUND(mi.price - SUM(bridge.quantity_used * i.cost_per_unit), 2) AS profit,
ROUND(((mi.price - SUM(bridge.quantity_used * i.cost_per_unit)) / mi.price) * 100, 1) AS profit_margin_pct
FROM mightyfine.menu_item_ingredients bridge
JOIN mightyfine.menu_items mi ON bridge.menu_item_id = mi.menu_item_id
JOIN mightyfine.ingredients i ON bridge.ingredient_id = i.ingredient_id
GROUP BY mi.item_name, mi.price
ORDER BY profit_margin_pct DESC;

-- ============================================================================
-- TASK 6.6: BUILD A RECEIPT WITH 8.25% TAX (3 pts)
-- ============================================================================
-- REQUIREMENTS:
--   A customer orders:  1 Double Mighty Burger, 1 Mighty Fine Fries,
--                        1 Chocolate Shake
--
--   Write a query using a CTE (WITH ... AS) that calculates:
--     subtotal    — sum of (price × quantity) for the three items
--     tax_8_25    — subtotal × 0.0825, rounded to 2 decimals
--     grand_total — subtotal × 1.0825, rounded to 2 decimals
--
-- HINT: Look at the Sales Ticket example in the hotdog lesson (Report 1).
-- ============================================================================

WITH receipt AS (
    SELECT mi.item_name, mi.price, si.quantity, (mi.price * si.quantity) AS line_total
    FROM mightyfine.sale_items si
    JOIN mightyfine.menu_items mi ON si.menu_item_id = mi.menu_item_id
    WHERE mi.item_name IN ('Double Mighty Burger', 'Mighty Fine Fries', 'Chocolate Shake')
)
SELECT
    ROUND(SUM(line_total), 2) AS subtotal,
    ROUND(SUM(line_total) * 0.0825, 2) AS tax_8_25,
    ROUND(SUM(line_total) * 1.0825, 2) AS grand_total
FROM receipt;

-- ============================================================================
-- END OF HOMEWORK
-- ============================================================================
-- Before submitting, make sure:
--   ✅  Every "YOUR CODE HERE" section has been replaced with working SQL.
--   ✅  Each query runs without errors when highlighted and executed.
--   ✅  You verified your row counts in Task 2.3.
--   ✅  Your file is saved (Ctrl+S).
-- ============================================================================
