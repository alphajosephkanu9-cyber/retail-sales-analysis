-- SECTION 09: PAYMENT & SALES CHANNEL ANALYSIS
-- This section is conditional. It checks whether the optional columns exist.
USE retail_analytics;

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'sales'
  AND COLUMN_NAME IN ('Payment_Method', 'Sales_Channel');

-- If Payment_Method exists, run this query:
-- SELECT Payment_Method, COUNT(DISTINCT Transaction_ID) AS transactions,
--        ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
--        ROUND(SUM(Quantity * Unit_Price * (1 - Discount))
--              / NULLIF(COUNT(DISTINCT Transaction_ID), 0), 2) AS average_transaction_value
-- FROM sales
-- WHERE Discount BETWEEN 0 AND 1
-- GROUP BY Payment_Method ORDER BY net_revenue DESC;

-- If Sales_Channel exists, run this query:
-- SELECT Sales_Channel, COUNT(DISTINCT Transaction_ID) AS transactions,
--        ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue
-- FROM sales
-- WHERE Discount BETWEEN 0 AND 1
-- GROUP BY Sales_Channel ORDER BY net_revenue DESC;

-- The optional queries are comments intentionally: MySQL cannot safely parse a
-- reference to a column that does not exist. Uncomment only the query for a
-- column confirmed by the INFORMATION_SCHEMA result. Do not create fake fields.
