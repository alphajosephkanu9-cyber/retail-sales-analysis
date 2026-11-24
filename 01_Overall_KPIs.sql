-- SECTION 01: OVERALL BUSINESS KPIs
USE retail_analytics;

SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(DISTINCT Transaction_ID) AS total_transactions,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(Quantity * Unit_Price), 2) AS gross_sales_before_discount,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
    ROUND(AVG(Unit_Price), 2) AS average_unit_price,
    ROUND(
        SUM(Quantity * Unit_Price * (1 - Discount))
        / NULLIF(COUNT(DISTINCT Transaction_ID), 0), 2
    ) AS average_transaction_value,
    COUNT(DISTINCT Customer_ID) AS unique_customers,
    COUNT(DISTINCT Product_ID) AS unique_products,
    COUNT(DISTINCT Store_ID) AS stores_involved
FROM sales
WHERE Quantity IS NOT NULL AND Unit_Price IS NOT NULL
  AND Discount BETWEEN 0 AND 1;

-- Total net revenue by year
-- Replace Sale_Date if required by your schema.
SELECT
    YEAR(Sale_Date) AS sales_year,
    COUNT(DISTINCT Transaction_ID) AS transactions,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue
FROM sales
WHERE Sale_Date IS NOT NULL
  AND Quantity IS NOT NULL AND Unit_Price IS NOT NULL
  AND Discount BETWEEN 0 AND 1
GROUP BY YEAR(Sale_Date)
ORDER BY sales_year;
