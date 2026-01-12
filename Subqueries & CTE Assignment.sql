-- Connect to database


-- ASSIGNMENT 1: Subqueries in the SELECT clause

-- View the products table
SELECT * FROM products;

-- View the average unit price
SELECT AVG(unit_price) AVG_UNIT_PRICE FROM products;

-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price

SELECT product_id, product_name, unit_price, 
(SELECT AVG(unit_price) AVG_UNIT_PRICE FROM products) AVG_UNIT_PRICE,
unit_price - (SELECT AVG(unit_price) AVG_UNIT_PRICE FROM products) DIFF_PRICE
FROM products;


-- Order the results from most to least expensive
SELECT product_id, product_name, unit_price, 
(SELECT AVG(unit_price) AVG_UNIT_PRICE FROM products) AVG_UNIT_PRICE,
unit_price - (SELECT AVG(unit_price) AVG_UNIT_PRICE FROM products) DIFF_PRICE
FROM products
WHERE unit_price IS NOT NULL
ORDER BY unit_price DESC;

-- ASSIGNMENT 2: Subqueries in the FROM clause

-- Return the factories, product names from the factory
-- and number of products produced by each factory


-- All factories and products
SELECT * FROM products;


-- All factories and their total number of products
SELECT factory, COUNT(*) FROM products
GROUP BY factory;

-- Final query with subqueries
SELECT pr.factory, pr.product_name
,pr_count.count
FROM products pr
LEFT JOIN (SELECT factory, COUNT(*) FROM products
GROUP BY factory) pr_count ON pr.factory = pr_count.factory
ORDER BY pr.factory, pr.product_name;

SELECT pr.factory, pr.product_name
,pr_count.count
FROM ( SELECT pr.factory, pr.product_name from products pr)
pr
LEFT JOIN (SELECT factory, COUNT(*) FROM products
GROUP BY factory) pr_count ON pr.factory = pr_count.factory
ORDER BY pr.factory, pr.product_name;
-- ASSIGNMENT 3: Subqueries in the WHERE clause

SELECT * FROM products;

-- View all products from Wicked Choccy's
SELECT * FROM products
WHERE factory = 'Wicked Choccy''s';

-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's
SELECT * FROM products
WHERE unit_price < ALL(SELECT unit_price FROM products
WHERE factory = 'Wicked Choccy''s');

SELECT * FROM products
WHERE unit_price > ALL(SELECT unit_price FROM products
WHERE factory = 'Wicked Choccy''s');


-- ASSIGNMENT 4: CTEs

-- View the orders and products tables
SELECT * FROM orders o
INNER JOIN products p on o.product_id = p.product_id;

-- Calculate the amount spent on each product, within each order
SELECT o.order_id,SUM(o.units * p.unit_price) total_sales FROM orders o
INNER JOIN products p on o.product_id = p.product_id
GROUP BY order_id
ORDER BY total_sales DESC;

-- Return all orders over $200

WITH order_sales AS( SELECT o.order_id,
							SUM(o.units * p.unit_price) total_sales 
					  FROM orders o
					  INNER JOIN products p on o.product_id = p.product_id
					  GROUP BY order_id
					  )
SELECT *
FROM order_sales os
WHERE os.total_sales > 200;

SELECT o.order_id,
							SUM(o.units * p.unit_price) total_sales 
FROM orders o
INNER JOIN products p on o.product_id = p.product_id
GROUP BY order_id
HAVING  SUM(o.units * p.unit_price) > 200;

-- Return the number of orders over $200

WITH order_sales AS( SELECT o.order_id,
							SUM(o.units * p.unit_price) total_sales 
					  FROM orders o
					  INNER JOIN products p on o.product_id = p.product_id
					  GROUP BY order_id
					  HAVING  SUM(o.units * p.unit_price) > 200
					  )
SELECT COUNT(*) total_orders_over_200
FROM order_sales os;

-- ASSIGNMENT 5: Multiple CTEs

-- Copy over Assignment 2 (Subqueries in the FROM clause) solution

SELECT factory, COUNT(*) FROM products
GROUP BY factory;

-- Rewrite the Assignment 2 subquery solution using CTEs instead
WITH pr_count as(SELECT factory, COUNT(*) FROM products
GROUP BY factory)
SELECT pr.factory, pr.product_name, pr_count.count
FROM products pr
LEFT JOIN pr_count on pr.factory = pr_count.factory
ORDER BY pr.factory, pr.product_name;

WITH pr as (SELECT pr.factory, pr.product_name from products pr),
pr_count as(SELECT factory, COUNT(*) FROM products
GROUP BY factory)
SELECT pr.factory, pr.product_name, pr_count.count
FROM pr
LEFT JOIN pr_count on pr.factory = pr_count.factory
ORDER BY pr.factory, pr.product_name;