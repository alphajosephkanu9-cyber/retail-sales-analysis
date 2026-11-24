-- SECTION 06: CUSTOMER ANALYSIS
USE retail_analytics;

-- Customer-level spend and purchase frequency
WITH customer_summary AS (
    SELECT c.Customer_ID, c.Customer_Name, c.City,
           COUNT(DISTINCT s.Transaction_ID) AS transactions,
           SUM(s.Quantity) AS units_purchased,
           SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)) AS net_revenue
    FROM customers c
    LEFT JOIN sales s ON c.Customer_ID = s.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.City
)
SELECT Customer_ID, Customer_Name, City, transactions, units_purchased,
       ROUND(net_revenue, 2) AS net_revenue,
       ROUND(net_revenue / NULLIF(transactions, 0), 2) AS revenue_per_transaction,
       CASE
           WHEN transactions = 0 THEN 'No Recorded Purchases'
           WHEN transactions = 1 THEN 'One-Time Customer'
           WHEN transactions BETWEEN 2 AND 3 THEN 'Occasional Customer'
           WHEN transactions BETWEEN 4 AND 9 THEN 'Regular Customer'
           ELSE 'Frequent Customer'
       END AS customer_group
FROM customer_summary
ORDER BY net_revenue DESC;

-- Customer group counts and revenue
WITH customer_counts AS (
    SELECT Customer_ID, COUNT(DISTINCT Transaction_ID) AS transactions,
           SUM(Quantity * Unit_Price * (1 - Discount)) AS net_revenue
    FROM sales
    WHERE Discount BETWEEN 0 AND 1
    GROUP BY Customer_ID
),
grouped AS (
    SELECT *,
       CASE WHEN transactions = 1 THEN 'One-Time Customers'
            WHEN transactions BETWEEN 2 AND 3 THEN 'Occasional Customers'
            WHEN transactions BETWEEN 4 AND 9 THEN 'Regular Customers'
            ELSE 'Frequent Customers' END AS customer_group
    FROM customer_counts
)
SELECT customer_group, COUNT(*) AS customers,
       ROUND(SUM(net_revenue), 2) AS net_revenue,
       ROUND(AVG(net_revenue), 2) AS average_revenue_per_customer
FROM grouped
GROUP BY customer_group
ORDER BY customers DESC;

-- Top 10 customers by revenue
SELECT c.Customer_ID, c.Customer_Name, c.City,
       COUNT(DISTINCT s.Transaction_ID) AS transactions,
       SUM(s.Quantity) AS units_bought,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue
FROM sales s JOIN customers c ON s.Customer_ID = c.Customer_ID
WHERE s.Discount BETWEEN 0 AND 1
GROUP BY c.Customer_ID, c.Customer_Name, c.City
ORDER BY net_revenue DESC LIMIT 10;

-- Revenue by customer city
SELECT c.City, COUNT(DISTINCT c.Customer_ID) AS customers,
       COUNT(DISTINCT s.Transaction_ID) AS transactions,
       ROUND(SUM(s.Quantity * s.Unit_Price * (1 - s.Discount)), 2) AS net_revenue
FROM customers c LEFT JOIN sales s ON c.Customer_ID = s.Customer_ID
WHERE s.Discount BETWEEN 0 AND 1
GROUP BY c.City ORDER BY net_revenue DESC;

-- Repeat customer rate: customers with >1 distinct transaction / purchasing customers
WITH frequency AS (
    SELECT Customer_ID, COUNT(DISTINCT Transaction_ID) AS transactions
    FROM sales GROUP BY Customer_ID
)
SELECT COUNT(*) AS purchasing_customers,
       SUM(transactions > 1) AS repeat_customers,
       ROUND(100 * SUM(transactions > 1) / NULLIF(COUNT(*), 0), 2) AS repeat_customer_rate_percent
FROM frequency;
