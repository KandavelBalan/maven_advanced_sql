
-- Connect to database


-- ASSIGNMENT 1: Numeric functions

-- Calculate the total spend for each customer
SELECT O.customer_id, 
SUM(O.units * P.UNIT_PRICE) TOTAL_SPEND,
FLOOR(SUM(O.units * P.UNIT_PRICE)/10) * 10 bins
FROM orders O
JOIN products p ON O.product_id = p.product_id
GROUP BY O.customer_id
ORDER BY TOTAL_SPEND;


-- Put the spend into bins of $0-$10, $10-20, etc.
-- Number of customers in each spend bin

WITH total_sp AS (
SELECT O.customer_id, 
SUM(O.units * P.UNIT_PRICE) TOTAL_SPEND,
FLOOR(SUM(O.units * P.UNIT_PRICE)/10) * 10 bins
FROM orders O
JOIN products p ON O.product_id = p.product_id
GROUP BY O.customer_id
ORDER BY TOTAL_SPEND)
SELECT bins, COUNT(customer_id) no_customers
FROM total_sp
GROUP BY bins
ORDER BY bins;

-- ASSIGNMENT 2: Datetime functions

SELECT order_id, order_date FROM orders;

-- Extract just the orders from Q2 2024

SELECT order_id, order_date FROM orders
where  EXTRACT(month from order_date) between 4 and 6
and  EXTRACT(year from order_date) = 2024;

-- Add a column called ship_date that adds 2 days to each order date

SELECT order_id, order_date, to_char((order_date + interval '2 days'),'yyyy-mm-dd') ship_date, 
cast((order_date + interval '2 days')as date) FROM orders
where  EXTRACT(month from order_date) between 4 and 6
and  EXTRACT(year from order_date) = 2024;

SELECT order_id, order_date, to_char((order_date + interval '2 days'),'yyyy-mm-dd') ship_date, 
cast((order_date + interval '2 days')as date) FROM orders
where order_date between '2024-04-01' and '2024-06-30';

SELECT order_id, order_date, to_char((order_date + interval '2 days'),'yyyy-mm-dd') ship_date, 
cast((order_date + interval '2 days')as date) FROM orders
where order_date >= '2024-04-01'
and   order_date <= '2024-06-30';