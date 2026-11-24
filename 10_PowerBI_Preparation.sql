-- SECTION 10: POWER BI DATA PREPARATION
-- These queries produce clean, analysis-ready tables for import into Power BI.
-- Confirm Sale_Date is the actual date field before running.
USE retail_analytics;

-- Fact table: one row per sales record, enriched with dimension labels.
SELECT s.Transaction_ID, s.Sale_Date, s.Customer_ID, s.Product_ID, s.Store_ID,
       s.Quantity, s.Unit_Price, s.Discount,
       (s.Quantity * s.Unit_Price) AS Sales_Before_Discount,
       (s.Quantity * s.Unit_Price * s.Discount) AS Discount_Amount,
       (s.Quantity * s.Unit_Price * (1 - s.Discount)) AS Net_Revenue,
       p.Unit_Cost,
       (s.Quantity * p.Unit_Cost) AS Estimated_Cost,
       (s.Quantity * (s.Unit_Price * (1 - s.Discount) - p.Unit_Cost))
           AS Estimated_Gross_Profit,
       p.Product_Name, p.Category,
       c.Customer_Name, c.City,
       st.Region
FROM sales s
LEFT JOIN products p ON s.Product_ID = p.Product_ID
LEFT JOIN customers c ON s.Customer_ID = c.Customer_ID
LEFT JOIN stores st ON s.Store_ID = st.Store_ID;

-- Dimension tables for Power BI
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM stores;

-- Calendar table: set the range to the actual sales date range.
WITH RECURSIVE calendar AS (
    SELECT DATE(MIN(Sale_Date)) AS calendar_date FROM sales WHERE Sale_Date IS NOT NULL
    UNION ALL
    SELECT calendar_date + INTERVAL 1 DAY
    FROM calendar
    WHERE calendar_date < (SELECT DATE(MAX(Sale_Date)) FROM sales WHERE Sale_Date IS NOT NULL)
)
SELECT calendar_date AS Date,
       YEAR(calendar_date) AS Year,
       QUARTER(calendar_date) AS Quarter_Number,
       CONCAT('Q', QUARTER(calendar_date)) AS Quarter,
       MONTH(calendar_date) AS Month_Number,
       DATE_FORMAT(calendar_date, '%M') AS Month_Name,
       DATE_FORMAT(calendar_date, '%Y-%m') AS Year_Month,
       WEEKDAY(calendar_date) + 1 AS Weekday_Number,
       DAYNAME(calendar_date) AS Weekday_Name
FROM calendar
ORDER BY calendar_date;
