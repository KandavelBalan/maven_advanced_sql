-- Assignments

-- 1.basic joins
-- Looking at the orders and products tables, which products exist in one table, but not the other?

SELECT * 
FROM products;

SELECT * 
FROM orders;

SELECT DISTINCT PR.product_name, 
PR.factory,
ORD.customer_id,
ORD.order_id
FROM products PR
INNER JOIN orders ORD 
	ON PR.product_id = ORD.product_id;

SELECT DISTINCT PR.product_name, 
PR.factory,
ORD.customer_id,
ORD.order_id
FROM products PR
LEFT JOIN orders ORD 
	ON PR.product_id = ORD.product_id
WHERE ORD.product_id IS NULL;

SELECT DISTINCT PR.product_name, 
PR.factory,
ORD.customer_id,
ORD.order_id
FROM products PR
RIGHT JOIN orders ORD 
	ON PR.product_id = ORD.product_id
WHERE PR.product_id IS NULL;


SELECT COUNT(*)
FROM orders O
LEFT JOIN products p 
	ON o.product_id = p.product_id; --8549

SELECT COUNT(*)
FROM orders O
RIGHT JOIN products p 
	ON o.product_id = p.product_id; --8552

-- final query
SELECT DISTINCT PR.product_name, 
PR.product_id,
ORD.product_id order_product_id,
ORD.customer_id,
ORD.order_id
FROM products PR
LEFT JOIN orders ORD 
	ON PR.product_id = ORD.product_id
WHERE ORD.product_id IS NULL;


-- ASSIGNMENT 2: Self Joins
-- Which products are within 25 cents of each other in terms of unit price?

-- View the products table
	SELECT * FROM PRODUCTS;

-- Join the products table with itself so each candy is paired with a different candy

	SELECT 	p1.product_name, p1.unit_price,
			p2.product_name, p2.unit_price
		FROM products p1
		INNER JOIN products p2 ON p1.product_id <> p2.product_id;
		
-- Calculate the price difference, do a self join, and then return only price differences under 25 cents

	SELECT 	p1.product_name, p1.unit_price,
			p2.product_name, p2.unit_price,
			p1.unit_price - p2.unit_price AS price_diff
		FROM products p1
		INNER JOIN products p2 ON p1.product_id <> p2.product_id
		WHERE 	p1.unit_price - p2.unit_price <= 0.25
				AND p1.unit_price - p2.unit_price > -0.25
		ORDER BY price_diff DESC;
		
	SELECT 	p1.product_name, p1.unit_price,
			p2.product_name, p2.unit_price,
			p1.unit_price - p2.unit_price AS price_diff
		FROM products p1
		INNER JOIN products p2 ON p1.product_id <> p2.product_id
		WHERE 	ABS(p1.unit_price - p2.unit_price) < 0.25
			AND p1.product_name < p2.product_name
		ORDER BY price_diff DESC;

-- CROSS JOIN
	SELECT 	p1.product_name, p1.unit_price,
			p2.product_name, p2.unit_price,
			p1.unit_price - p2.unit_price AS price_diff
		FROM products p1
		CROSS JOIN products p2 
		WHERE 	ABS(p1.unit_price - p2.unit_price) < 0.25
			AND p1.product_id <> p2.product_id
			AND p1.product_name < p2.product_name
		ORDER BY price_diff DESC;