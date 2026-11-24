-- SECTION 08: PROFITABILITY ANALYSIS
-- Estimated gross profit only; operating expenses are not included.
USE retail_analytics;

-- Overall estimated profitability
SELECT
    ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
    ROUND(SUM(s.Quantity * p.Unit_Cost), 2) AS estimated_cost,
    ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
        AS estimated_gross_profit,
    ROUND(100 * SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost))
          / NULLIF(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 0), 2)
        AS gross_profit_margin_percent
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Quantity IS NOT NULL AND s.Unit_Price IS NOT NULL
  AND p.Unit_Cost IS NOT NULL AND s.Discount BETWEEN 0 AND 1;

-- Profitability by category
SELECT p.Category,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(SUM(s.Quantity * p.Unit_Cost), 2) AS estimated_cost,
       ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
           AS estimated_gross_profit,
       ROUND(100 * SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost))
             / NULLIF(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 0), 2)
           AS gross_margin_percent
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Discount BETWEEN 0 AND 1 AND p.Unit_Cost IS NOT NULL
GROUP BY p.Category ORDER BY estimated_gross_profit DESC;

-- Profitability by store and region
SELECT st.Store_ID, st.Region,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(SUM(s.Quantity * p.Unit_Cost), 2) AS estimated_cost,
       ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
           AS estimated_gross_profit
FROM sales s JOIN stores st ON s.Store_ID = st.Store_ID
JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Discount BETWEEN 0 AND 1 AND p.Unit_Cost IS NOT NULL
GROUP BY st.Store_ID, st.Region ORDER BY estimated_gross_profit DESC;

-- Lowest estimated gross profit products (includes negative values)
SELECT p.Product_ID, p.Product_Name, p.Category,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(SUM(s.Quantity * p.Unit_Cost), 2) AS estimated_cost,
       ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
           AS estimated_gross_profit,
       ROUND(100 * SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost))
             / NULLIF(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 0), 2)
           AS gross_margin_percent
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Discount BETWEEN 0 AND 1 AND p.Unit_Cost IS NOT NULL
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY estimated_gross_profit ASC LIMIT 15;
