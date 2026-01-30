-- 1. DUPLICATE VALUES

CREATE TABLE employee_details (
    region VARCHAR(50),
    employee_name VARCHAR(50),
    salary INTEGER
);

INSERT INTO employee_details (region, employee_name, salary) VALUES
	('East', 'Ava', 85000),
	('East', 'Ava', 85000),
	('East', 'Bob', 72000),
	('East', 'Cat', 59000),
	('West', 'Cat', 63000),
	('West', 'Dan', 85000),
	('West', 'Eve', 72000),
	('West', 'Eve', 75000);

-- View the employee details table
SELECT * FROM employee_details;

-- View duplicate rows

-- 1. View duplicate employees

SELECT employee_name, count(*)
FROM employee_details
group by employee_name 
having count(*) > 1;

-- 2. View duplicate region + employee combos

SELECT employee_name,region, count(*)
FROM employee_details
group by employee_name,region 
having count(*) > 1;

-- 3. View fully duplicate rows

SELECT employee_name,region, salary, count(*)
FROM employee_details
group by employee_name,region, salary
having count(*) > 1;

-- Exclude duplicate rows

-- 1. Exclude fully duplicate rows

SELECT Distinct employee_name,region, salary
FROM employee_details;

-- 2. Exclude partially duplicate rows (unique employee name for each row)

Select * 
From (
SELECT employee_name, region, salary,
		row_number() over(partition by employee_name order by salary desc) dup_value
FROM employee_details)
Where dup_value = 1;

-- 3. Exclude partially duplicate rows (unique region + employee name for each row)

Select * 
From (
SELECT employee_name, region, salary,
		row_number() over(partition by employee_name,region order by salary desc) dup_value
FROM employee_details)
Where dup_value = 1;

-- 2. MIN / MAX VALUE FILTERING

CREATE TABLE sales (
    id INT PRIMARY KEY,
    sales_rep VARCHAR(50),
    date DATE,
    sales INT
);

INSERT INTO sales (id, sales_rep, date, sales) VALUES 
    (1, 'Emma', '2024-08-01', 6),
    (2, 'Emma', '2024-08-02', 17),
    (3, 'Jack', '2024-08-02', 14),
    (4, 'Emma', '2024-08-04', 20),
    (5, 'Jack', '2024-08-05', 5),
    (6, 'Emma', '2024-08-07', 1);

-- View the sales table

SELECT * FROM sales;

-- Goal: Return the most recent sales amount for each sales rep

-- Return the most recent sales date for each sales rep

SELECT sales_rep, max(date) most_recent_date
FROM sales
group by sales_rep;

-- Return the most recent sales date for each sales rep + attempt to add on the sales

SELECT sales_rep, max(date) most_recent_date,
	max(sales) top_sales
FROM sales
group by sales_rep;

-- Number of sales on most recent date: Group by + join approach

With top_sales as(
SELECT sales_rep, max(date) top_date
FROM sales
group by sales_rep
)
select s.sales_rep, s.date, s.sales
from sales s
join top_sales tp on s.sales_rep = tp.sales_rep
	and s.date = tp.top_date;
                
-- Number of sales on most recent date: Window function approach

Select *
From
	(Select sales_rep, date, sales, row_number() over(partition by sales_rep order by date desc) row_num
	from sales) top_sales
where row_num = 1;

-- 3. PIVOTING

CREATE TABLE pizza_table (
    category VARCHAR(50),
    crust_type VARCHAR(50),
    pizza_name VARCHAR(100),
    price DECIMAL(5, 2)
);

INSERT INTO pizza_table (category, crust_type, pizza_name, price) VALUES
    ('Chicken', 'Gluten-Free Crust', 'California Chicken', 21.75),
    ('Chicken', 'Thin Crust', 'Chicken Pesto', 20.75),
    ('Classic', 'Standard Crust', 'Greek', 21.50),
    ('Classic', 'Standard Crust', 'Hawaiian', 19.50),
    ('Classic', 'Standard Crust', 'Pepperoni', 18.75),
    ('Supreme', 'Standard Crust', 'Spicy Italian', 22.75),
    ('Veggie', 'Thin Crust', 'Five Cheese', 18.50),
    ('Veggie', 'Thin Crust', 'Margherita', 19.50),
    ('Veggie', 'Gluten-Free Crust', 'Garden Delight', 21.50);

-- View the pizza table
SELECT * FROM pizza_table;

-- Create 1/0 columns

SELECT 
CASE WHEN crust_type = 'Standard Crust' THEN price ELSE 0 END AS "Standard Crust",
CASE WHEN crust_type = 'Thin Crust' THEN price ELSE 0 END AS "Thin Crust",
CASE WHEN crust_type = 'Gluten-Free Crust' THEN price ELSE 0 END AS "Gluten-Free Crust"
FROM pizza_table;

-- Create a summary table of categories & pizza types

SELECT Category,
SUM(CASE WHEN crust_type = 'Standard Crust' THEN 1 ELSE 0 END) AS "Standard Crust",
SUM(CASE WHEN crust_type = 'Thin Crust' THEN 1 ELSE 0 END) AS "Thin Crust",
SUM(CASE WHEN crust_type = 'Gluten-Free Crust' THEN 1 ELSE 0 END) AS "Gluten-Free Crust"
FROM pizza_table
Group By Category;

-- 4. ROLLING CALCULATIONS

-- Create a pizza orders table
CREATE TABLE pizza_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    order_date DATE,
    pizza_name VARCHAR(100),
    price DECIMAL(5, 2)
);

INSERT INTO pizza_orders (order_id, customer_name, order_date, pizza_name, price) VALUES
    (1, 'Jack', '2024-12-01', 'Pepperoni', 18.75),
    (2, 'Jack', '2024-12-02', 'Pepperoni', 18.75),
    (3, 'Jack', '2024-12-03', 'Pepperoni', 18.75),
    (4, 'Jack', '2024-12-04', 'Pepperoni', 18.75),
    (5, 'Jack', '2024-12-05', 'Spicy Italian', 22.75),
    (6, 'Jill', '2024-12-01', 'Five Cheese', 18.50),
    (7, 'Jill', '2024-12-03', 'Margherita', 19.50),
    (8, 'Jill', '2024-12-05', 'Garden Delight', 21.50),
    (9, 'Jill', '2024-12-05', 'Greek', 21.50),
    (10, 'Tom', '2024-12-02', 'Hawaiian', 19.50),
    (11, 'Tom', '2024-12-04', 'Chicken Pesto', 20.75),
    (12, 'Tom', '2024-12-05', 'Spicy Italian', 22.75),
    (13, 'Jerry', '2024-12-01', 'California Chicken', 21.75),
    (14, 'Jerry', '2024-12-02', 'Margherita', 19.50),
    (15, 'Jerry', '2024-12-04', 'Greek', 21.50);
    
-- View the table
SELECT * FROM pizza_orders;

-- 1. Calculate the sales subtotals for each customer

	SELECT customer_name, order_date, price
	FROM pizza_orders;

	SELECT customer_name, order_date, SUM(price) total_sales
	FROM pizza_orders
	GROUP BY customer_name, order_date
	ORDER BY customer_name, order_date;
	
-- View the total sales for each customer on each date

	SELECT customer_name, order_date, SUM(price) total_sales
	FROM pizza_orders
	GROUP BY customer_name, order_date
	ORDER BY customer_name, order_date;

-- Include the subtotals

	SELECT customer_name, order_date, SUM(price) total_sales
	FROM pizza_orders
	GROUP BY ROLLUP(customer_name, order_date)
	ORDER BY customer_name, order_date;

-- 2. Calculate the cumulative sum of sales over time

-- View the columns of interest

SELECT	order_date, price
FROM	pizza_orders
ORDER BY order_date;

-- Calculate the total sales for each day

SELECT order_date, SUM(price)
FROM	pizza_orders
GROUP BY order_date
ORDER BY order_date;

-- Calculate the cumulative sales over time

WITH cs AS(SELECT order_date, SUM(price) cum_sales
			FROM	pizza_orders
			GROUP BY order_date
			ORDER BY order_date)
SELECT order_date, cum_sales, SUM(cum_sales) OVER(ORDER BY order_date)
FROM cs;

-- 3. Calculate the 3 year moving average of happiness scores for each country

-- View the happiness score table

SELECT * FROM happiness_scores;

-- View the happiness scores for each country, sorted by year

SELECT country, year, happiness_score 
FROM happiness_scores
ORDER BY country, year;

-- Create a basic row number window function

SELECT country, year, happiness_score,
	ROW_NUMBER() OVER(PARTITION BY country ORDER BY year) row_num
FROM happiness_scores
ORDER BY country, year;

-- Update the function to a moving average calculation

SELECT country, year, happiness_score,
	round(AVG(happiness_score) OVER(PARTITION BY country ORDER BY year 
							  ROWS BETWEEN 2 preceding and current row),2) avg_2_yrs
FROM happiness_scores
ORDER BY country, year;

-- 5. FINAL DEMO: Imputing NULL Values

/* Stock prices table was created in prior section:
   This is the code if you need to create it again */

 -- Create a stock prices table
CREATE TABLE IF NOT EXISTS stock_prices (
    date DATE PRIMARY KEY,
    price DECIMAL(10, 2)
);

INSERT INTO stock_prices (date, price) VALUES
	('2024-11-01', 678.27),
	('2024-11-03', 688.83),
	('2024-11-04', 645.40),
	('2024-11-06', 591.01); 
    
-- Recursive CTE from earlier
WITH RECURSIVE my_dates(dt) AS (SELECT CAST('2024-11-01' AS DATE)
								UNION ALL
								SELECT CAST(dt + INTERVAL '1 DAY' AS DATE)
								FROM my_dates
								WHERE dt < '2024-11-06')
     
SELECT	md.dt, sp.price
FROM	my_dates md
		LEFT JOIN stock_prices sp
        ON md.dt = sp.date
ORDER BY md.dt;
        
-- Let's replace the NULL values in the price column 4 different ways (aka imputation)
-- 1. With a hard coded value
-- 2. With a subquery
-- 3. With one window function
-- 4. With two window functions

WITH RECURSIVE my_dates(dt) AS (SELECT CAST('2024-11-01' AS DATE)
								UNION ALL
								SELECT CAST(dt + INTERVAL '1 DAY' AS DATE)
								FROM my_dates
								WHERE dt < '2024-11-06'),
                                
	 sp AS (SELECT	md.dt, sp.price
			FROM	my_dates md
					LEFT JOIN stock_prices sp
					ON md.dt = sp.date)
                    
SELECT	dt, price,
		COALESCE(price, 600) AS updated_price_600,
        COALESCE(price, ROUND((SELECT AVG(price) FROM sp), 2)) AS updated_price_avg,
        COALESCE(price, LAG(price) OVER( ORDER BY dt)) AS updated_price_prior,
        COALESCE(price, ROUND((LAG(price) OVER(ORDER BY dt) + LEAD(price) OVER(ORDER BY dt))/2, 2)) AS updated_price_smooth
FROM	sp
ORDER BY dt;


