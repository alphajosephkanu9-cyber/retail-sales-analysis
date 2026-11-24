-- SECTION 05: STORE & REGIONAL ANALYSIS
USE retail_analytics;

-- Store performance
SELECT st.Store_ID, st.Region,
       COUNT(DISTINCT s.Transaction_ID) AS transactions,
       SUM(s.Quantity) AS units_sold,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount))
             / NULLIF(COUNT(DISTINCT s.Transaction_ID), 0), 2) AS average_transaction_value,
       ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
             AS estimated_gross_profit,
       DENSE_RANK() OVER (
           ORDER BY SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)) DESC
       ) AS store_revenue_rank
FROM sales s
JOIN stores st ON s.Store_ID = st.Store_ID
LEFT JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Unit_Price IS NOT NULL AND s.Discount BETWEEN 0 AND 1
GROUP BY st.Store_ID, st.Region
ORDER BY net_revenue DESC;

-- Regional performance and share
SELECT st.Region,
       COUNT(DISTINCT s.Store_ID) AS stores,
       COUNT(DISTINCT s.Transaction_ID) AS transactions,
       SUM(s.Quantity) AS units_sold,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(100 * SUM(s.Quantity * s.Unit_Price * (1 - s.Discount))
             / NULLIF(SUM(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount))) OVER (), 0), 2)
             AS revenue_contribution_percent
FROM sales s JOIN stores st ON s.Store_ID = st.Store_ID
WHERE s.Unit_Price IS NOT NULL AND s.Discount BETWEEN 0 AND 1
GROUP BY st.Region ORDER BY net_revenue DESC;

-- Monthly store performance; requires Sale_Date (change name if needed)
SELECT st.Store_ID, st.Region, DATE_FORMAT(s.Sale_Date, '%Y-%m') AS year_month,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       COUNT(DISTINCT s.Transaction_ID) AS transactions
FROM sales s JOIN stores st ON s.Store_ID = st.Store_ID
WHERE s.Sale_Date IS NOT NULL AND s.Discount BETWEEN 0 AND 1
GROUP BY st.Store_ID, st.Region, DATE_FORMAT(s.Sale_Date, '%Y-%m')
ORDER BY st.Store_ID, year_month;
