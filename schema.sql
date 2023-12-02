-- In this SQL file, write (and comment!) the schema of your database,
-- including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- List of customers and their basic information
DROP TABLE IF EXISTS "customers";
CREATE TABLE "customers" (
    "id" INTEGER,
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "homeAddressID" INTEGER DEFAULT NULL,
    "phoneNum" TEXT,
    PRIMARY KEY ("id")
    FOREIGN KEY ("homeAddressID") REFERENCES "addresses"("id")
);

-- List of orders of customers
DROP TABLE IF EXISTS "orders";
CREATE TABLE "orders" (
    "id" INTEGER,
    "customerID" INTEGER,
    "deliveryAddressID" INTEGER NOT NULL,
    "bill" DECIMAL(10, 2),
    "status" TEXT NOT NULL DEFAULT 'Processing'
        CHECK("status" IN ('Processing', 'In Transit', 'Delivered')),
    "orderDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "deliveryETA" DATE NOT NULL,
    "riderID" INTEGER NOT NULL,
    "size" TEXT,
    "weight" TEXT,
    "payment" TEXT CHECK("payment" IN ('Unpaid', 'Paid')) DEFAULT 'Unpaid',
    PRIMARY KEY ("id"),
    FOREIGN KEY ("customerID") REFERENCES "customers" ("id"),
    FOREIGN KEY ("deliveryAddressID") REFERENCES "addresses" ("id"),
    FOREIGN KEY ("riderID") REFERENCES "riders" ("id")
);

-- List of products in all stores
DROP TABLE IF EXISTS "products";
CREATE TABLE "products" (
    "id" INTEGER,
    "storeID" INTEGER NOT NULL DEFAULT 1,
    "productCode" TEXT NOT NULL UNIQUE,
    "product" TEXT NOT NULL,
    "img_path" TEXT DEFAULT '/img_src/logo.png',
    "pricePerUnit" DECIMAL(10, 2) NOT NULL,
    "stock" INTEGER NOT NULL DEFAULT 0 CHECK("stock" >= 0),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("storeID") REFERENCES "stores" ("id")
);

-- List of items per order placed by customers
DROP TABLE IF EXISTS "line-item";
CREATE TABLE "line-item" (
    "orderID" INTEGER NOT NULL,
    "productID" INTEGER NOT NULL,
    "quantity" INTEGER,
    FOREIGN KEY ("orderID") REFERENCES "orders"("id"),
    FOREIGN KEY ("productID") REFERENCES "products"("id")
);

-- List of all stores
-- Unique constraint on the combination of name and location
DROP TABLE IF EXISTS "stores";
CREATE TABLE "stores" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "location" INTEGER NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("location") REFERENCES "addresses" ("id"),
    UNIQUE ("name", "location")
);

-- List of all address associated to the users
DROP TABLE IF EXISTS "addresses";
CREATE TABLE "addresses" (
    "id" INTEGER,
    "address" TEXT UNIQUE CHECK (address <> '' AND address IS NOT NULL),
    PRIMARY KEY ("id")
);

-- List of riders and their basic info
DROP TABLE IF EXISTS "riders";
CREATE TABLE "riders" (
    "id" INTEGER,
    "rider" TEXT NOT NULL,
    "plateNum" TEXT NOT NULL UNIQUE,
    "vehicle" TEXT NOT NULL,
    "vehicle_desc" TEXT,
    "age" INTEGER NOT NULL,
    "homeAddressID" INTEGER NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("homeAddressID") REFERENCES "addresses" ("id")
);

-- Shows the list of products the customers ordered
DROP VIEW IF EXISTS "orders_per_customer";
CREATE VIEW "orders_per_customer" AS
    SELECT
        "orders"."customerID",
        "products"."product",
        "line-item"."quantity",
        "products"."pricePerUnit" AS 'price'
    FROM
        "orders"
    JOIN "customers" ON "customers"."id" = "orders"."customerID"
    JOIN "line-item" ON "orders"."id" = "line-item"."orderID"
    JOIN "products" ON "line-item"."productID" = "products"."id"
;

-- View for the riders when viewing their deliveries
DROP VIEW IF EXISTS "rider_checks_delivery";
CREATE VIEW "rider_checks_delivery" AS
    SELECT
        "riderID",
        "orders"."id" AS 'orderID',
        "customers"."name",
        "addresses"."address",
        "orders"."deliveryETA" AS 'ETA',
        "size",
        "weight",
        "status",
        "payment"
    FROM "orders"
    JOIN "addresses" ON "orders"."deliveryAddressID" = "addresses"."id"
    JOIN "customers" ON "customers"."id" = "orders"."customerID"
    ORDER BY "deliveryETA"
;

-- Shows the list of products available to be purchase,
-- including the ones with zero stock.
-- But excluding the products from unregistered stores (storeID = 1).
DROP VIEW IF EXISTS "product_list";
CREATE VIEW "product_list" AS
    SELECT
        "product",
        "pricePerUnit" AS 'price',
        "stock",
        (   SELECT "name" FROM "stores"
            WHERE "id" = "products"."storeID") AS 'store'
    FROM "products"
    WHERE "storeID" != 1
    ORDER BY
        "product"
;

-- Create a trigger that handles both deleting orders and updating stock
DROP TRIGGER IF EXISTS "deleting_order_and_update_stock";
CREATE TRIGGER "deleting_order_and_update_stock"
    AFTER DELETE ON "orders"
    BEGIN
        -- Delete line items related to the deleted order
        DELETE FROM "line-item"
        WHERE "orderID" = OLD."id";

        -- Update stock of products for the deleted line items
        UPDATE "products"
        SET "stock" = "stock" + (
            SELECT "quantity"
            FROM "line-item"
            WHERE "orderID" = OLD."id"
        )
        WHERE "id" IN (
            SELECT "productID"
            FROM "line-item"
            WHERE "orderID" = OLD."id"
        );
    END
;

-- Create a trigger that updates stock of a product when an line-item is deleted
DROP TRIGGER IF EXISTS "updating_stock_upon_cancel";
CREATE TRIGGER "updating_stock_upon_cancel"
    BEFORE DELETE ON "line-item"
    BEGIN
        UPDATE "products"
        SET "stock" = "stock" + OLD."quantity"
        WHERE "id" = OLD."productID";
    END
;

-- Creating an index for the customer IDs in "orders" table for inserting on "line-item"
DROP INDEX IF EXISTS "customerID_in";
CREATE INDEX "customerID_in" ON "orders" ("customerID");

-- Creating an index for the productIDs in the line-item table
DROP INDEX IF EXISTS "productID_in";
CREATE INDEX "productID_in" ON "line-item" ("productID");

-- Creating an index for the products in "orders" table for inserting on "line-item"
DROP INDEX IF EXISTS "products_in";
CREATE INDEX "products_in" ON "products" ("product");
