-- SECTION 04: PRODUCT PERFORMANCE ANALYSIS
USE retail_analytics;

-- Top 15 products by net revenue
SELECT p.Product_ID, p.Product_Name, p.Category,
       SUM(s.Quantity) AS units_sold,
       COUNT(DISTINCT s.Transaction_ID) AS transactions,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Quantity IS NOT NULL AND s.Unit_Price IS NOT NULL
  AND s.Discount BETWEEN 0 AND 1
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY net_revenue DESC LIMIT 15;

-- Top 15 products by units sold
SELECT p.Product_ID, p.Product_Name, p.Category, SUM(s.Quantity) AS units_sold
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY units_sold DESC LIMIT 15;

-- Product revenue, cost, estimated gross profit and margin
SELECT p.Product_ID, p.Product_Name, p.Category,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(SUM(s.Quantity * p.Unit_Cost), 2) AS estimated_cost,
       ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
           AS estimated_gross_profit,
       ROUND(100 * SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost))
             / NULLIF(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 0), 2)
           AS gross_margin_percent
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Quantity > 0 AND s.Unit_Price IS NOT NULL
  AND s.Discount BETWEEN 0 AND 1 AND p.Unit_Cost IS NOT NULL
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY estimated_gross_profit DESC;

-- Products with no recorded sales
SELECT p.Product_ID, p.Product_Name, p.Category
FROM products p
LEFT JOIN sales s ON p.Product_ID = s.Product_ID
WHERE s.Product_ID IS NULL
ORDER BY p.Product_Name;

-- Lowest revenue products with at least one recorded sale
SELECT p.Product_ID, p.Product_Name, p.Category,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       SUM(s.Quantity) AS units_sold
FROM products p JOIN sales s ON p.Product_ID = s.Product_ID
WHERE s.Unit_Price IS NOT NULL AND s.Discount BETWEEN 0 AND 1
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY net_revenue ASC LIMIT 15;
