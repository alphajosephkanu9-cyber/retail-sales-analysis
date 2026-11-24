-- SECTION 07: DISCOUNT ANALYSIS
USE retail_analytics;

-- Discount distribution and performance
SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10 THEN 'Low Discount (1-10%)'
        WHEN Discount > 0.10 AND Discount <= 0.20 THEN 'Medium Discount (11-20%)'
        WHEN Discount > 0.20 THEN 'High Discount (Above 20%)'
        ELSE 'Invalid or Missing'
    END AS discount_group,
    COUNT(*) AS sales_rows,
    COUNT(DISTINCT Transaction_ID) AS transactions,
    SUM(Quantity) AS units_sold,
    ROUND(AVG(Discount) * 100, 2) AS average_discount_percent,
    ROUND(SUM(Quantity * Unit_Price), 2) AS sales_before_discount,
    ROUND(SUM(Quantity * Unit_Price * Discount), 2) AS discount_amount,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue
FROM sales
GROUP BY discount_group
ORDER BY net_revenue DESC;

-- Products most frequently sold with a discount
SELECT p.Product_ID, p.Product_Name, p.Category,
       COUNT(*) AS discounted_sales_rows,
       ROUND(AVG(s.Discount) * 100, 2) AS average_discount_percent,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE s.Discount > 0 AND s.Discount <= 1
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY discounted_sales_rows DESC LIMIT 15;

-- Compare discounted and non-discounted rows
SELECT
    CASE WHEN Discount = 0 THEN 'No Discount' ELSE 'Discount Applied' END AS discount_status,
    COUNT(DISTINCT Transaction_ID) AS transactions,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
    ROUND(SUM(Quantity * (Unit_Price * (1 - Discount) - p.Unit_Cost)), 2) AS estimated_gross_profit
FROM sales s JOIN products p ON s.Product_ID = p.Product_ID
WHERE Discount BETWEEN 0 AND 1 AND Unit_Price IS NOT NULL AND p.Unit_Cost IS NOT NULL
GROUP BY discount_status;
