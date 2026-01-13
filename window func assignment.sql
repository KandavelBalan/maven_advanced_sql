-- Connect to database


-- ASSIGNMENT 1: Window function basics

-- View the orders table
	SELECT * FROM orders;

-- View the columns of interest
	SELECT customer_id, order_id, order_date, transaction_id
	FROM orders;

-- For each customer, add a column for transaction number
	SELECT customer_id,order_id, order_date, transaction_id,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) transaction_number
	FROM orders;

		SELECT customer_id,order_id, order_date, transaction_id,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_id) transaction_number
	FROM orders;

-- ASSIGNMENT 2: Row Number vs Rank vs Dense Rank

-- View the columns of interest

   SELECT order_id, product_id, units
   FROM orders
   ORDER BY  units DESC;

-- Try ROW_NUMBER to rank the units
  
 SELECT order_id, product_id, units, 
      ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY units DESC) product_rank
   FROM orders
   ORDER BY order_id, product_id;
   
-- For each order, rank the products from most units to fewest units
-- If there's a tie, keep the tie and don't skip to the next number after
  SELECT order_id, product_id, units, 
      RANK() OVER(PARTITION BY order_id ORDER BY units DESC) product_rank
   FROM orders;

-- Check the order id that ends with 44262 from the results preview

 SELECT order_id, product_id, units, 
      DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) product_rank
   FROM orders;

 SELECT order_id, product_id, units, 
      DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) product_rank
   FROM orders
   WHERE order_id LIKE '%44262';

-- ASSIGNMENT 3: First Value vs Last Value vs Nth Value

-- View the rankings from the last assignment

SELECT order_id, product_id, units, 
      DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) product_rank
   FROM orders;

-- Add a column that contains the 2nd most popular product

SELECT order_id, product_id, units, 
      NTH_VALUE(units,2) OVER(PARTITION BY order_id ORDER BY units DESC) sec_product
   FROM orders;
   
-- Return the 2nd most popular product for each order

WITH pop_product AS(
SELECT order_id, product_id, units, 
      NTH_VALUE(product_id,2) OVER(PARTITION BY order_id ORDER BY units DESC) pop_pro
   FROM orders)
SELECT * 
FROM pop_product
WHERE product_id = pop_pro;
   
-- Alternative using DENSE RANK


SELECT order_id, product_id, units, 
      DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) pop_pro
FROM orders;

-- Add a column that contains the rankings



-- Return the 2nd most popular product for each order

WITH pop_product AS(
SELECT order_id, product_id, units, 
      DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) pop_pro
   FROM orders)
SELECT * 
FROM pop_product
WHERE pop_pro = 2;


-- ASSIGNMENT 4: Lead & Lag

-- View the columns of interest
	SELECT customer_id, order_id, units
	FROM orders;

-- For each customer, return the total units within each order

	SELECT customer_id, order_id, SUM(units) total_units
	FROM orders
	GROUP BY customer_id, 
	order_id;

-- Add on the transaction id to keep track of the order of the orders

	SELECT customer_id, order_id, 
	SUM(units) total_units,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_id) transaction_id
	FROM orders
	GROUP BY customer_id, 
	order_id;

	SELECT customer_id, order_id, 
	SUM(units) total_units,
	 transaction_id
	FROM orders
	GROUP BY customer_id, 
	order_id, transaction_id
	ORDER BY customer_id, transaction_id;
	
-- Turn the query into a CTE and view the columns of interest

	WITH prev_order AS(	SELECT customer_id, order_id, 
	SUM(units) total_units,
	 transaction_id
	FROM orders
	GROUP BY customer_id, 
	order_id, transaction_id
	ORDER BY customer_id, transaction_id)
	SELECT customer_id, order_id, 
	 total_units
	FROM prev_order;
	
-- Create a prior units column

	WITH prev_order AS(	
	SELECT customer_id, order_id, 
	SUM(units) total_units,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_id) transaction_id
	FROM orders
	GROUP BY customer_id, 
	order_id)
	SELECT customer_id, order_id, total_units,
		LAG(total_units) OVER(PARTITION BY customer_id ORDER BY order_id) prior_order_units
	FROM prev_order;

-- For each customer, find the change in units per order over time

	WITH prev_order AS(	
	SELECT customer_id, order_id, 
	SUM(units) total_units,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_id) transaction_id
	FROM orders
	GROUP BY customer_id, 
	order_id)
	, units_calc AS(SELECT customer_id, order_id, total_units,
		LAG(total_units) OVER(PARTITION BY customer_id ORDER BY order_id) prior_order_units
	FROM prev_order)
	SELECT 	customer_id, order_id, total_units, prior_order_units,
			total_units - prior_order_units diff_units
	FROM units_calc;

-- ASSIGNMENT 5: NTILE

-- Calculate the total amount spent by each customer


-- View the data needed from the orders table
	SELECT * FROM 
		orders;

-- View the data needed from the products table
	SELECT * FROM
		products;

-- Combine the two tables and view the columns of interest

	SELECT customer_id, orders.order_id, orders.units, products.unit_price
	FROM orders
	JOIN products ON orders.product_id = products.product_id;
        
-- Calculate the total spending by each customer and sort the results from highest to lowest

	SELECT customer_id, SUM(orders.units * products.unit_price) sales
	FROM orders
	JOIN products ON orders.product_id = products.product_id
	GROUP BY customer_id
	ORDER BY SALES desc;
	
-- Turn the query into a CTE and apply the percentile calculation

WITH cte AS(
	SELECT customer_id, SUM(orders.units * products.unit_price) sales
	FROM orders
	JOIN products ON orders.product_id = products.product_id
	GROUP BY customer_id
	ORDER BY SALES desc
)
SELECT customer_id, sales,
		NTILE(100) OVER(ORDER BY sales DESC) top_sales
FROM cte;

-- Return the top 1% of customers in terms of spending

WITH cte AS(
	SELECT customer_id, SUM(orders.units * products.unit_price) sales
	FROM orders
	JOIN products ON orders.product_id = products.product_id
	GROUP BY customer_id
	ORDER BY SALES desc
)
, top_cust AS(
	SELECT customer_id, sales,
		NTILE(100) OVER(ORDER BY sales DESC) top_sales
FROM cte)
SELECT * 
FROM top_cust
WHERE top_sales = 1;
