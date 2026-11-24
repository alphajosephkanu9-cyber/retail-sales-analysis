-- SECTION 00: DATA QUALITY & DATA INSPECTION
-- Purpose: identify issues before using the data. This script does not modify source data.
USE retail_analytics;

SHOW TABLES;
DESCRIBE customers;
DESCRIBE products;
DESCRIBE stores;
DESCRIBE sales;

-- Row counts
SELECT 'sales' AS table_name, COUNT(*) AS row_count FROM sales
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'stores', COUNT(*) FROM stores;

-- Missing values in important sales fields
SELECT
    SUM(Transaction_ID IS NULL) AS missing_transaction_id,
    SUM(Customer_ID IS NULL) AS missing_customer_id,
    SUM(Product_ID IS NULL) AS missing_product_id,
    SUM(Store_ID IS NULL) AS missing_store_id,
    SUM(Quantity IS NULL) AS missing_quantity,
    SUM(Unit_Price IS NULL) AS missing_unit_price,
    SUM(Discount IS NULL) AS missing_discount
FROM sales;

-- Duplicate transaction IDs: a transaction ID can legitimately appear on multiple product lines.
-- This query flags IDs appearing more than once; inspect whether these are expected line items.
SELECT Transaction_ID, COUNT(*) AS rows_for_transaction
FROM sales
WHERE Transaction_ID IS NOT NULL
GROUP BY Transaction_ID
HAVING COUNT(*) > 1
ORDER BY rows_for_transaction DESC;

-- Exact duplicate sales rows across the available business columns
SELECT Transaction_ID, Customer_ID, Product_ID, Store_ID, Quantity, Unit_Price, Discount,
       COUNT(*) AS duplicate_count
FROM sales
GROUP BY Transaction_ID, Customer_ID, Product_ID, Store_ID, Quantity, Unit_Price, Discount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Invalid quantity and price
SELECT
    SUM(Quantity < 0) AS negative_quantity_rows,
    SUM(Quantity = 0) AS zero_quantity_rows,
    SUM(Unit_Price < 0) AS negative_price_rows,
    SUM(Unit_Price = 0) AS zero_price_rows
FROM sales;

-- Discount validation: expected scale is 0 to 1
SELECT Discount, COUNT(*) AS row_count
FROM sales
WHERE Discount IS NULL OR Discount < 0 OR Discount > 1
GROUP BY Discount
ORDER BY Discount;

-- Unmatched foreign keys
SELECT 'customer' AS key_type, COUNT(*) AS unmatched_sales_rows
FROM sales s LEFT JOIN customers c ON s.Customer_ID = c.Customer_ID
WHERE s.Customer_ID IS NOT NULL AND c.Customer_ID IS NULL
UNION ALL
SELECT 'product', COUNT(*)
FROM sales s LEFT JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Product_ID IS NOT NULL AND p.Product_ID IS NULL
UNION ALL
SELECT 'store', COUNT(*)
FROM sales s LEFT JOIN stores st ON s.Store_ID = st.Store_ID
WHERE s.Store_ID IS NOT NULL AND st.Store_ID IS NULL;

-- Unmatched key details
SELECT s.Customer_ID, COUNT(*) AS affected_rows
FROM sales s LEFT JOIN customers c ON s.Customer_ID = c.Customer_ID
WHERE s.Customer_ID IS NOT NULL AND c.Customer_ID IS NULL
GROUP BY s.Customer_ID ORDER BY affected_rows DESC;

SELECT s.Product_ID, COUNT(*) AS affected_rows
FROM sales s LEFT JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Product_ID IS NOT NULL AND p.Product_ID IS NULL
GROUP BY s.Product_ID ORDER BY affected_rows DESC;

SELECT s.Store_ID, COUNT(*) AS affected_rows
FROM sales s LEFT JOIN stores st ON s.Store_ID = st.Store_ID
WHERE s.Store_ID IS NOT NULL AND st.Store_ID IS NULL
GROUP BY s.Store_ID ORDER BY affected_rows DESC;

-- Blank or missing descriptive attributes
SELECT COUNT(*) AS products_with_missing_category
FROM products WHERE Category IS NULL OR TRIM(Category) = '';

SELECT COUNT(*) AS customers_with_missing_city
FROM customers WHERE City IS NULL OR TRIM(City) = '';

-- Date range: replace Sale_Date if your actual date column has a different name.
-- Run only after confirming the column exists.
SELECT MIN(Sale_Date) AS first_sale_date, MAX(Sale_Date) AS last_sale_date
FROM sales;
