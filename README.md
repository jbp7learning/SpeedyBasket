# SpeedyBasket.db

**Video overview:** [`SpeedyBasket.db (Database) in SQLite`](https://youtu.be/n9cogYo7Afo)

## Scope

The purpose of this database is to manage a delivery service, handling customer accounts, orders, product information, and rider details. The scope includes customers, riders, addresses, stores, products, orders, and associated line-item details. It does not encompass information about employees beyond customers and riders, extended geographical details, other product types, detailed product specifications, broader business processes, or temporal data. The focus is on core aspects of order fulfillment and delivery service management.

## Functional Requirements

* **User Actions:**
   - **Customer:**
     - Create a new account.
     - Place orders, including specifying products and quantities.
     - View order history.
   - **Rider:**
     - Create a rider account.
     - View and update delivery-related information.
   - **Administrator:**
     - Add new products and stores.
     - Manage customer and rider accounts.
     - Monitor and update order and product information.

* **Beyond User Scope:**
   - **Customer:**
     - Modifying order details after placement.
     - Accessing or altering rider-specific information.
   - **Rider:**
     - Modifying customer order details.
     - Accessing or altering other rider information.
   - **Administrator:**
     - Direct involvement in order-specific details.
     - Accessing or altering personal user accounts.

## Representation

### Entities

These entity descriptions define the key attributes for each entity in the database. The types and constraints were chosen to ensure data integrity, uniqueness, and proper relationships between entities, reflecting the requirements of a delivery service management system.

1. **Customers:**
   - **Attributes:**
     - `id` (INTEGER, PRIMARY KEY): Unique identifier for each customer.
     - `username` (TEXT, UNIQUE): Customer's unique username.
     - `password` (TEXT): Password for account security.
     - `name` (TEXT): Customer's full name.
     - `homeAddressID` (INTEGER, FOREIGN KEY): Reference to the customer's home address.
     - `phoneNum` (TEXT): Customer's contact number.

2. **Orders:**
   - **Attributes:**
     - `id` (INTEGER, PRIMARY KEY): Unique identifier for each order.
     - `customerID` (INTEGER, FOREIGN KEY): Reference to the customer placing the order.
     - `deliveryAddressID` (INTEGER, FOREIGN KEY): Reference to the delivery address.
     - `bill` (DECIMAL(10, 2)): Total cost of the order.
     - `status` (TEXT, DEFAULT 'Processing'): Order status (Processing, In Transit, Delivered).
     - `orderDate` (DATE): Date when the order was placed.
     - `deliveryETA` (DATE): Estimated time of delivery.
     - `riderID` (INTEGER, NOT NULL, FOREIGN KEY): Reference to the assigned rider.
     - `size` (TEXT): Size information of the order.
     - `weight` (TEXT): Weight information of the order.
     - `payment` (TEXT, DEFAULT 'Unpaid'): Payment status (Unpaid, Paid).

3. **Products:**
   - **Attributes:**
     - `id` (INTEGER, PRIMARY KEY): Unique identifier for each product.
     - `storeID` (INTEGER, NOT NULL, FOREIGN KEY): Reference to the store where the product is available.
     - `productCode` (TEXT, UNIQUE): Unique code identifying the product.
     - `product` (TEXT): Name of the product.
     - `img_path` (TEXT, DEFAULT '/img_src/logo.png'): Image path for the product.
     - `pricePerUnit` (DECIMAL(10, 2)): Price per unit of the product.
     - `stock` (INTEGER, DEFAULT 0): Quantity of the product in stock.

4. **Line-Item:**
   - **Attributes:**
     - `orderID` (INTEGER, NOT NULL, FOREIGN KEY): Reference to the order to which the item belongs.
     - `productID` (INTEGER, NOT NULL, FOREIGN KEY): Reference to the product in the order.
     - `quantity` (INTEGER): Quantity of the product in the order.

5. **Stores:**
   - **Attributes:**
     - `id` (INTEGER, PRIMARY KEY): Unique identifier for each store.
     - `name` (TEXT): Name of the store.
     - `location` (INTEGER, NOT NULL, FOREIGN KEY): Reference to the store's location (address).

6. **Addresses:**
   - **Attributes:**
     - `id` (INTEGER, PRIMARY KEY): Unique identifier for each address.
     - `address` (TEXT, UNIQUE): Textual representation of the address.

7. **Riders:**
   - **Attributes:**
     - `id` (INTEGER, PRIMARY KEY): Unique identifier for each rider.
     - `rider` (TEXT): Rider's name.
     - `plateNum` (TEXT, UNIQUE): Unique identifier for the rider's vehicle.
     - `vehicle` (TEXT): Type of vehicle used by the rider.
     - `vehicle_desc` (TEXT): Description of the rider's vehicle.
     - `age` (INTEGER): Age of the rider.
     - `homeAddressID` (INTEGER, NOT NULL, FOREIGN KEY): Reference to the rider's home address.


### Relationships

These relationships are established through foreign key constraints, ensuring data integrity and allowing for efficient querying of related information. They reflect the connections between customers, orders, products, stores, addresses, and riders in the context of a delivery service management system.

[![SpeedyBasket](https://mermaid.ink/img/pako:eNqVVE1v4jAQ_SuWz4CS8pXkhkgOSEupErisuLj2tLU2sbOOU5UF_vs6iYGE0qImJ8-8eX7z4dljKhngAG8FqJCTV0WyrUDmm2-S9WoZxQk6HPp9uUezMIyjJIkSFKAtJkUhKSca2BY3Aas4rNBHgz4cWuEVOk8J_QoZL8ITzJDyV_EVsCtAS_QMiEHK30FdQn4tHqP-Yh0tTdRgYKIsRxVCpdCEi-Iz9tDc8BSvws18fUYLoK0Ez95azx6ZBGMrhgtUaEn_nKDWZYFd4amk7bLZ9G9CbXa14Orv9mXfGKqPC404u5w1fGgkSAZdiOXbzRhTUBSN89ip9Tek1ZmWJs8M1CL8lrntZkB5RlL0zNO0ZTU10DwDJBUDtSQMbvhOrNF61tF6adyV3JqsfXldiFxJVlJ9rflvSYTmetehPjf5XnUt6Vy2ldceBgVVPNdcis9VyBWn8ARqI7juXGxH5udNNQ1RcKujdrJ-xtjklpoOPJbZlfkd3jhN76Zrr7-M8j0F5Eo87mEzYhnhzCymOtg89zcwMnH9KoiqH9rR4EipZbITFAdaldDDZV4Nj11kOHghaWGsORG_pcxOIHPEwR5_4KA_9QbO0Bu5I3849l1_5PXwzpgfPH8wdKZTdzx2Ju5w4h57-F_N4A5G44nj-N5k5DlT98HvYWDctGDZ7NF6nR7_Ax8YkW4?type=png)](https://mermaid.live/edit#pako:eNqVVE1v4jAQ_SuWz4CS8pXkhkgOSEupErisuLj2tLU2sbOOU5UF_vs6iYGE0qImJ8-8eX7z4dljKhngAG8FqJCTV0WyrUDmm2-S9WoZxQk6HPp9uUezMIyjJIkSFKAtJkUhKSca2BY3Aas4rNBHgz4cWuEVOk8J_QoZL8ITzJDyV_EVsCtAS_QMiEHK30FdQn4tHqP-Yh0tTdRgYKIsRxVCpdCEi-Iz9tDc8BSvws18fUYLoK0Ez95azx6ZBGMrhgtUaEn_nKDWZYFd4amk7bLZ9G9CbXa14Orv9mXfGKqPC404u5w1fGgkSAZdiOXbzRhTUBSN89ip9Tek1ZmWJs8M1CL8lrntZkB5RlL0zNO0ZTU10DwDJBUDtSQMbvhOrNF61tF6adyV3JqsfXldiFxJVlJ9rflvSYTmetehPjf5XnUt6Vy2ldceBgVVPNdcis9VyBWn8ARqI7juXGxH5udNNQ1RcKujdrJ-xtjklpoOPJbZlfkd3jhN76Zrr7-M8j0F5Eo87mEzYhnhzCymOtg89zcwMnH9KoiqH9rR4EipZbITFAdaldDDZV4Nj11kOHghaWGsORG_pcxOIHPEwR5_4KA_9QbO0Bu5I3849l1_5PXwzpgfPH8wdKZTdzx2Ju5w4h57-F_N4A5G44nj-N5k5DlT98HvYWDctGDZ7NF6nR7_Ax8YkW4)

## Optimizations

### Materialized Views

1. **"orders_per_customer" View:**
   - **Purpose:** Consolidates information related to customer orders for efficient querying. For example, a query where the customer checks their orders.

2. **"rider_checks_delivery" View:**
   - **Purpose:** Provides a summarized view of order details for quick analysis for the drivers. Like for example, a rider checking the order information for a customer.

### Filtered Views

1. **"product_list" View:**
   - **Purpose:** Simplifies the product list by excluding products from unregistered stores. A view fit for queries where the customers checks the items they can buy.

### Triggers

1. **"update_product_stock" Trigger:**
   - **Purpose:** Updates product stock after each purchase to reflect changes.

2. **"deleting_order_and_update_stock" Trigger:**
   - **Purpose:** Deletes line items and updates stock when an order is deleted to maintain data consistency.
     - **Action 1:** Deletes line items related to the deleted order.
     - **Action 2:** Updates stock of products by adding back the quantities from the deleted line items.

### Indexes

1. **"customerID" Index in "orders" Table:**
   - **Purpose:** Enhances query performance for joins and referential integrity.

2. **"productID" Index in "line-item" Table:**
   - **Purpose:** Improves performance for joins and queries involving line items.

3. **"product" Index in "products" Table:**
   - **Purpose:** Accelerates data retrieval for queries involving product searches.


## Limitations

### Lack of Full Text Search:

- **Limitation:** The current database design does not incorporate full-text search capabilities.
- **Explanation:** If your application requires advanced text search functionality, such as searching for products or customers based on keywords, the existing design might not be optimized for this use case. Implementing full-text search might involve additional considerations and modifications.

### Limited Support for Complex Hierarchical Relationships:

- **Limitation:** The design might face limitations in representing complex hierarchical relationships.
- **Explanation:** If your application involves complex hierarchical structures beyond the current scope (e.g., nested categories or organizational hierarchies), the existing table structure may not be the most suitable. Considerations for hierarchical data representation might need to be revisited.

### Lack of Advanced Security Mechanisms:

- **Limitation:** The current design lacks advanced security mechanisms.
- **Explanation:** If your application requires fine-grained access control, auditing, or more sophisticated security features, additional measures might need to be implemented. This could involve role-based access control (RBAC) or other security frameworks.

### Minimal Consideration for Scalability:

- **Limitation:** The database design might have limitations in terms of scalability.
- **Explanation:** While the current design is suitable for small to medium-sized applications, it may require adjustments for larger-scale scenarios. Considerations for horizontal scalability, partitioning, and optimization for high concurrency scenarios might need to be explored for future scalability requirements.
