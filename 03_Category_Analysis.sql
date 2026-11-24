-- SECTION 03: PRODUCT CATEGORY ANALYSIS
USE retail_analytics;

SELECT p.Category,
       COUNT(DISTINCT s.Transaction_ID) AS transactions,
       SUM(s.Quantity) AS units_sold,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue,
       ROUND(100 * SUM(s.Quantity * s.Unit_Price * (1 - s.Discount))
             / NULLIF(SUM(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount))) OVER (), 0), 2)
             AS revenue_contribution_percent,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount))
             / NULLIF(SUM(s.Quantity), 0), 2) AS average_net_selling_price,
       ROUND(SUM(s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost)), 2)
             AS estimated_gross_profit,
       DENSE_RANK() OVER (
           ORDER BY SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)) DESC
       ) AS revenue_rank
FROM sales s
JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Quantity IS NOT NULL AND s.Unit_Price IS NOT NULL
  AND s.Discount BETWEEN 0 AND 1
GROUP BY p.Category
ORDER BY net_revenue DESC;
