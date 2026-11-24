-- SECTION 02: SALES TRENDS & TIME ANALYSIS
-- Assumed date field: Sale_Date. Change it to the actual date column if needed.
USE retail_analytics;

-- Revenue by year
SELECT YEAR(Sale_Date) AS sales_year,
       ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
       COUNT(DISTINCT Transaction_ID) AS transactions
FROM sales
WHERE Sale_Date IS NOT NULL AND Discount BETWEEN 0 AND 1
GROUP BY YEAR(Sale_Date) ORDER BY sales_year;

-- Revenue, units and transactions by month
SELECT YEAR(Sale_Date) AS sales_year,
       MONTH(Sale_Date) AS month_number,
       DATE_FORMAT(Sale_Date, '%Y-%m') AS year_month,
       ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
       SUM(Quantity) AS units_sold,
       COUNT(DISTINCT Transaction_ID) AS transactions
FROM sales
WHERE Sale_Date IS NOT NULL AND Discount BETWEEN 0 AND 1
GROUP BY YEAR(Sale_Date), MONTH(Sale_Date), DATE_FORMAT(Sale_Date, '%Y-%m')
ORDER BY sales_year, month_number;

-- Month-over-month revenue and percentage change
WITH monthly_sales AS (
    SELECT DATE_FORMAT(Sale_Date, '%Y-%m-01') AS month_start,
           SUM(Quantity * Unit_Price * (1 - Discount)) AS net_revenue
    FROM sales
    WHERE Sale_Date IS NOT NULL AND Discount BETWEEN 0 AND 1
    GROUP BY YEAR(Sale_Date), MONTH(Sale_Date)
),
with_previous AS (
    SELECT month_start, net_revenue,
           LAG(net_revenue) OVER (ORDER BY month_start) AS previous_month_revenue
    FROM monthly_sales
)
SELECT month_start, ROUND(net_revenue, 2) AS net_revenue,
       ROUND(previous_month_revenue, 2) AS previous_month_revenue,
       ROUND((net_revenue - previous_month_revenue)
             / NULLIF(previous_month_revenue, 0) * 100, 2) AS mom_growth_percent
FROM with_previous ORDER BY month_start;

-- Sales by day of week (1=Monday ... 7=Sunday)
SELECT WEEKDAY(Sale_Date) + 1 AS weekday_number,
       DAYNAME(Sale_Date) AS weekday_name,
       ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
       COUNT(DISTINCT Transaction_ID) AS transactions,
       SUM(Quantity) AS units_sold
FROM sales
WHERE Sale_Date IS NOT NULL AND Discount BETWEEN 0 AND 1
GROUP BY WEEKDAY(Sale_Date), DAYNAME(Sale_Date)
ORDER BY weekday_number;

-- Sales by day of month
SELECT DAY(Sale_Date) AS day_of_month,
       ROUND(SUM(Quantity * Unit_Price * (1 - Discount)), 2) AS net_revenue,
       COUNT(DISTINCT Transaction_ID) AS transactions
FROM sales
WHERE Sale_Date IS NOT NULL AND Discount BETWEEN 0 AND 1
GROUP BY DAY(Sale_Date) ORDER BY day_of_month;

-- Best and worst individual year-month periods in the dataset
WITH monthly AS (
    SELECT DATE_FORMAT(Sale_Date, '%Y-%m') AS year_month,
           SUM(Quantity * Unit_Price * (1 - Discount)) AS net_revenue
    FROM sales
    WHERE Sale_Date IS NOT NULL AND Discount BETWEEN 0 AND 1
    GROUP BY YEAR(Sale_Date), MONTH(Sale_Date)
)
(SELECT 'Highest revenue month' AS result_type, year_month, ROUND(net_revenue, 2) AS net_revenue
 FROM monthly ORDER BY net_revenue DESC LIMIT 1)
UNION ALL
(SELECT 'Lowest revenue month', year_month, ROUND(net_revenue, 2)
 FROM monthly ORDER BY net_revenue ASC LIMIT 1);
