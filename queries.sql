-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Product and Store-related Queries:
    -- CREATING NEW STORE ACCOUNTS
    -- ADDING PRODUCTS

-- Customer-related Queries:
    -- CREATING NEW CUSTOMER ACCOUNTS
    -- CUSTOMER VIEWING THE PRODUCTS

-- Order-related Queries:
    -- A CUSTOMER PLACES ORDERS
    -- A CUSTOMER CANCELS AN ORDER
    -- CHECKING THE LIST OF ORDERS OF A CUSTOMER

-- Rider-related Queries:
    -- CREATING NEW RIDER ACCOUNTS
    -- A RIDER CHECKS ORDERS TO BE DELIVERED
    -- UPDATING THE ORDERS'S PAYMENT STATUS


------------------------ CREATING NEW STORE ACCOUNTS ------------------------

-- Adding the address/es of the new store/s if applicable to "addresses" table:
INSERT OR IGNORE INTO "addresses" ("address")
VALUES ('No Location');

INSERT OR IGNORE INTO "addresses" ("address")
VALUES
    ('Diagon Alley, London, UK'),
    ('Chocolate Ave, England'),
    ('Bikini Bottom, Pacific Ocean'),
    ('Main Street, Disneyland'),
    ('Diagon Alley, London, UK'),
    ('221B Mystic Lane, Ravenclaw Village, Magical Realm'),
    ('10880 Malibu Point, Malibu, California')
;

INSERT OR IGNORE INTO "stores" ("name", "location")
VALUES (
    'Unregistered Store',
    (SELECT "id" FROM "addresses" WHERE "address" = 'No Location')
);

-- Adding the stores' information:
INSERT OR IGNORE INTO "stores" ("name", "location")
VALUES
    (   'Ollivanders Wand Shop',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = 'Diagon Alley, London, UK')
    ),
    (   'Wonka''s Chocolate Factory',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = 'Chocolate Ave, England')
    ),
    (   'Krusty Krab',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = 'Bikini Bottom, Pacific Ocean')
    ),
    (   'The Sword and the Stone',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = 'Main Street, Disneyland')
    ),
    (   'Weasleys'' Wizard Wheezes',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = 'Diagon Alley, London, UK')
    ),
    (   'Mystic Emporium',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = '221B Mystic Lane, Ravenclaw Village, Magical Realm')
    ),
    (   'Stark Industries Tech Store',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = '10880 Malibu Point, Malibu, California')
    )
;


------------------------ ADDING PRODUCTS ------------------------

-- Importing the products information from a .CSV file
DROP TABLE IF EXISTS "temp";
.import --csv import.csv temp

-- Adding the imported products info to the "products" table
-- code,products,store,stock,image,price
INSERT OR IGNORE INTO "products" (
    "storeID", "productCode", "product", "img_path", "pricePerUnit", "stock")
SELECT
    COALESCE(
        (SELECT "id" FROM "stores" WHERE "name" = "temp"."store"),
        (SELECT "id" FROM "stores" WHERE "name" = 'Unregistered Store')
    ),
    "temp"."code",
    "products",
    "image",
    "price",
    "stock"
FROM "temp";

DROP TABLE IF EXISTS "temp";

DROP INDEX IF EXISTS "product_in";
CREATE INDEX "product_in" ON "products" ("product");


------------------------ CREATING NEW RIDER ACCOUNTS ------------------------

-- Step 1: Add the addresses
INSERT OR IGNORE INTO "addresses" ("address")
VALUES
    ('30 Rockefeller Plaza, New York, NY'),
    ('1600 Smith Street, Houston, TX'),
    ('200 Park Avenue, Manhattan');

-- Step 2: Add the riders' information
INSERT OR IGNORE INTO "riders" ("rider", "plateNum", "vehicle", "vehicle_desc", "age", "homeAddressID")
VALUES
    (
        'Liz Lemon',
        'NA663R',
        'Mini Truck',
        'White Lifan',
        '40',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = '30 Rockefeller Plaza, New York, NY')
    ),
    (
        'JR Ewing',
        'P1LAT3',
        'Mini Van',
        'Black Suzuki Every',
        '36',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = '1600 Smith Street, Houston, TX')
    ),
    (
        'Natasha Romanoff',
        'BLW678',
        'Motorcycle',
        'Harley-Davidson LiveWire',
        '32',
        (   SELECT "id" FROM "addresses"
            WHERE "address" = '200 Park Avenue, Manhattan')
    );


------------------------ CREATING NEW CUSTOMER ACCOUNTS ------------------------

-- Step 1: Insert or retrieve the address ID
INSERT OR IGNORE INTO "addresses" ("address") VALUES ('1 Infinite Loop, Cupertino, CA'); -- Use the actual address
INSERT OR IGNORE INTO "addresses" ("address") VALUES ('Greenwich Village, NY'); -- WAS ADDED
INSERT OR IGNORE INTO "addresses" ("address") VALUES (NULL); -- NOT ADDED
INSERT OR IGNORE INTO "addresses" ("address") VALUES (''); -- NOT ADDED

-- Step 2: Insert the new customer
INSERT INTO "customers" ("username", "password", "name", "homeAddressID")
VALUES
    (   'ironman11',
        '0d94d92e3dc096f64213a5b34fa9d098',
        'Tony Stark',
        (SELECT "id" FROM "addresses" WHERE "address" = '1 Infinite Loop, Cupertino, CA')
    ),
    (   'agamoto2.0',
        '823b88d0e2e0205c32dff8a1be1204e0',
        'Stephen Strange',
        (SELECT "id" FROM "addresses" WHERE "address" = 'Greenwich Village, NY')
    ),
    (   'blueIron21',
        '0d94d92e3dc096f64213a5b34fa9d098',
        'Morgan Potts',
        (SELECT "id" FROM "addresses" WHERE "address" = NULL)
    ), -- homeAddressID = NULL
    (   'spidey11',
        'c66ff418af50eb1dea25194d6452131c',
        'Peter Benjamin Parker',
        (SELECT "id" FROM "addresses" WHERE "address" = '')
    ) -- homeAddressID = NULL
;


------------------------ CUSTOMER VIEWING THE PRODUCTS ------------------------

-- Products with 0 stock are still included
-- but products from unregistered stores (storeID = 0) are not.
SELECT * FROM "product_list";


------------------------ A CUSTOMER PLACES ORDERS ------------------------

BEGIN TRANSACTION;
-- Step 1: If customer gave an address, add it to "addresses" table.
INSERT INTO "addresses" ("address")
VALUES ('20 Ingram St., Queens');
-- Step 2: Add an order
INSERT INTO "orders" (
    "customerID", "deliveryAddressID", "status", "orderDate", "deliveryETA", "riderID")
VALUES
    (4, (SELECT "id" FROM "addresses" WHERE "address" = '20 Ingram St., Queens'),
    'Processing', CURRENT_DATE, DATE('now', '+7 days'), 2);
-- Step 3: Add items in "line-item"
INSERT INTO "line-item" ("orderID", "productID", "quantity")
VALUES
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 4), 7, 5);
-- Step 4: Update bill
UPDATE "orders"
SET "bill" = (
    SELECT SUM("line-item"."quantity" * "products"."pricePerUnit")
    FROM "line-item"
    JOIN "products" ON "line-item"."productID" = "products"."id"
    WHERE "line-item"."orderID" = (
        SELECT MAX("id")
        FROM "orders"
        WHERE "customerID" = 4
    )
) WHERE "id" = (
    SELECT MAX("id")
    FROM "orders"
    WHERE "customerID" = 4
); -- Replace with the actual order ID
COMMIT;


BEGIN TRANSACTION;
-- PLACE ANOTTHER ORDER
-- Step 1: If customer gave an address, add it to "addresses" table.
INSERT INTO "addresses" ("address") VALUES ('177A Bleecker Street, NY');
-- Step 2: Add an order
INSERT INTO "orders" ("customerID", "deliveryAddressID", "status", "orderDate", "deliveryETA", "riderID")
VALUES (2, (SELECT "id" FROM "addresses" WHERE "address" = '177A Bleecker Street, NY'),
    'Processing', CURRENT_DATE, DATE('now', '+14 days'), 2);
-- Step 3: Add items in "line-item"
INSERT INTO "line-item" ("orderID", "productID", "quantity")
VALUES
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 2), 6, 1),
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 2), 26, 1),
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 2), 29, 1),
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 2), 23, 1);
-- Step 4: Update bill
UPDATE "orders"
SET "bill" = (
    SELECT SUM("line-item"."quantity" * "products"."pricePerUnit")
    FROM "line-item"
    JOIN "products" ON "line-item"."productID" = "products"."id"
    WHERE "line-item"."orderID" = (
        SELECT MAX("id")
        FROM "orders"
        WHERE "customerID" = 2
    )
) WHERE "id" = (
    SELECT MAX("id")
    FROM "orders"
    WHERE "customerID" = 2
);
COMMIT;


BEGIN TRANSACTION;
    -- PLACE ANOTTHER ORDER
    -- Step 1: If customer gave an address, add it to "addresses" table.
    -- INSERT INTO "addresses" ("address")
    -- VALUES ('');
    -- Step 2: Add an order
    INSERT INTO "orders" ("customerID", "deliveryAddressID", "status", "orderDate", "deliveryETA", "riderID")
    VALUES (1, (SELECT "homeAddressID" FROM "customers" WHERE "id" = 1),
        'Processing', CURRENT_DATE, DATE('now', '+3 days'), 2);
    -- Step 3: Add items in "line-item"
    INSERT INTO "line-item" ("orderID", "productID", "quantity")
    VALUES
        ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 1), 7, 1),
        ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 1), 27, 1),
        ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 1), 30, 1),
        ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 1), 24, 1);
    -- Step 4: Update bill
    UPDATE "orders"
    SET "bill" = (
        SELECT SUM("li"."quantity" * "p"."pricePerUnit")
        FROM "line-item" AS "li"
        JOIN "products" AS "p" ON "li"."productID" = "p"."id"
        WHERE "li"."orderID" = "orders"."id"
    )
    WHERE "id" = (
        SELECT MAX("id")
        FROM "orders"
        WHERE "customerID" = 1
    );
COMMIT;


-- Start a transaction
BEGIN TRANSACTION;
-- Step 1: If the customer gave an address, add it to "addresses" table.
-- Step 2: Add an order
INSERT INTO "orders" ("customerID", "deliveryAddressID", "status", "orderDate", "deliveryETA", "riderID")
VALUES (
    3,
    COALESCE((SELECT "id" FROM "addresses" WHERE "address" = 'Greenwich Village, NY'), NULL),
    'Processing',
    CURRENT_DATE,
    DATE('now', '+6 days'),
    2
);
-- Step 3: Add items in "line-item"
INSERT INTO "line-item" ("orderID", "productID", "quantity")
VALUES
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 3), 29, 1),
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 3), 12, 1),
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 3), 24, 2),
    ((SELECT MAX("id") FROM "orders" WHERE "customerID" = 3), 30, 1);
-- Step 4: Update bill
UPDATE "orders"
SET "bill" = (
    SELECT SUM("li"."quantity" * "p"."pricePerUnit")
    FROM "line-item" AS "li"
    JOIN "products" AS "p" ON "li"."productID" = "p"."id"
    WHERE "li"."orderID" = (
        SELECT MAX("id") FROM "orders"
        WHERE "customerID" = 3
    )
)
WHERE "id" = (
    SELECT MAX("id") FROM "orders"
    WHERE "customerID" = 3
);
-- Commit the transaction
COMMIT;


------------------------ A CUSTOMER CANCELS AN ORDER ------------------------

DELETE FROM "orders" WHERE "id" = 1;
-- Executes TRIGGER "deleting_order"


------------------------ CHECKING THE LIST OF ORDERS OF A CUSTOMER ------------------------

-- Query to check the list of orders of customer Tony Stark (customerID = 1)
SELECT "product", "quantity", "price"
FROM "orders_per_customer"
WHERE "customerID" = 2;


------------------------ A RIDER CHECKS ORDERS TO BE DELIVERED ------------------------
-- Inventory Managers updates size and weight of orders
UPDATE "orders" SET "size" = '10cmX17cm', "weight" = '1.2kg' WHERE "id" = 2;
UPDATE "orders" SET "size" = '15cmX6cm', "weight" = '0.5kg' WHERE "id" = 3;

-- Rider actually checking orders to be delivered
SELECT "orderID", "name", "address", "ETA", "size", "weight", "status", "payment"
FROM "rider_checks_delivery"
WHERE "riderID" = 2; -- Replace with actual rider's id

-- Rider delivers changes orders' status
UPDATE "orders" SET "status" = 'In Transit' WHERE "id" = 2;
UPDATE "orders" SET "status" = 'Delivered' WHERE "id" = 3;

SELECT "orderID", "name", "address", "ETA", "size", "weight", "status", "payment"
FROM "rider_checks_delivery"
WHERE "riderID" = 2;


------------------------ UPDATING THE ORDERS'S PAYMENT STATUS ------------------------
-- Updating payment status
UPDATE "orders"
SET "payment" = 'Paid'
WHERE "id" = 3;
