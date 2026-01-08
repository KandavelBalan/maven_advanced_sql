-- 1. Basic joins
SELECT * 
FROM happiness_scores;

SELECT *
FROM country_stats;

SELECT happiness_scores.year, 
	happiness_scores.country, 
	happiness_scores.happiness_score,
	country_stats.country,
	country_stats.population
FROM happiness_scores
	INNER JOIN country_stats on happiness_scores.country = country_stats.country;

SELECT hs.year, 
	hs.country, 
	hs.happiness_score,
	cs.country,
	cs.population
FROM happiness_scores hs
	INNER JOIN country_stats cs on hs.country = cs.country;

-- 2. Join types
SELECT hs.year, 
	hs.country, 
	hs.happiness_score,
	cs.country,
	cs.population
FROM happiness_scores hs
	INNER JOIN country_stats cs on hs.country = cs.country;

SELECT hs.year, 
	hs.country, 
	hs.happiness_score,
	cs.country,
	cs.population
FROM happiness_scores hs
	LEFT JOIN country_stats cs on hs.country = cs.country
WHERE cs.country IS NULL;

SELECT hs.year, 
	hs.country, 
	hs.happiness_score,
	cs.country,
	cs.population
FROM happiness_scores hs
	RIGHT JOIN country_stats cs on hs.country = cs.country
WHERE hs.country ISNULL;

SELECT hs.year, 
	hs.country, 
	hs.happiness_score,
	cs.country,
	cs.population
FROM happiness_scores hs
	FULL OUTER JOIN country_stats cs on hs.country = cs.country
WHERE cs.country ISNULL
OR hs.country ISNULL;

-- 3. Joining on multiple columns

SELECT * 
FROM happiness_scores;

SELECT *
FROM country_stats;

SELECT * 
FROM inflation_rates;

SELECT HS."year", HS.country, HS.happiness_score, IR.inflation_rate
FROM happiness_scores HS
	INNER JOIN inflation_rates IR ON HS.country = IR.country_name --1611
 			AND HS."year" = IR."year"; --179

-- 4. Joining multiple tables

SELECT * FROM happiness_scores;

SELECT * FROM country_stats;

SELECT * FROM inflation_rates;

SELECT * 
FROM happiness_scores hs 
		LEFT JOIN country_stats cs 
			ON hs.country = cs.country
		LEFT JOIN inflation_rates ir
			ON hs.country = ir.country_name
			AND hs."year" = ir."year";

-- self joins
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    salary INT,
    manager_id INT
);

INSERT INTO employees (employee_id, employee_name, salary, manager_id) VALUES
	(1, 'Ava', 85000, NULL),
	(2, 'Bob', 72000, 1),
	(3, 'Cat', 59000, 1),
	(4, 'Dan', 85000, 2);

SELECT * 
FROM employees;

-- Employees with the same salary
SELECT 	e1.employee_id, e1.employee_name, e1.salary,
		e2.employee_id, e2.employee_name, e2.salary
FROM employees e1
INNER JOIN employees e2 
		ON e1.salary = e2.salary
WHERE e1.employee_id > e2.employee_id;

-- Employees that have a greater salary
SELECT e1.employee_id, e1.employee_name, e1.salary,
		e2.employee_id, e2.employee_name, e2.salary
FROM employees e1
INNER JOIN employees e2 on e1.salary > e2.salary;

-- Employees and their managers
select
e1.employee_id, e1.employee_name, e1.salary,
		e2.employee_id, e2.employee_name, e2.salary
FROM employees e1
LEFT JOIN employees e2 
		ON e1.manager_id = e2.employee_id;

-- 6. Cross joins
CREATE TABLE tops (
    id INT,
    item VARCHAR(50)
);

CREATE TABLE sizes (
    id INT,
    size VARCHAR(50)
);

CREATE TABLE outerwear (
    id INT,
    item VARCHAR(50)
);

INSERT INTO tops (id, item) VALUES
	(1, 'T-Shirt'),
	(2, 'Hoodie');

INSERT INTO sizes (id, size) VALUES
	(101, 'Small'),
	(102, 'Medium'),
	(103, 'Large');

INSERT INTO outerwear (id, item) VALUES
	(2, 'Hoodie'),
	(3, 'Jacket'),
	(4, 'Coat');
    
-- View the tables

SELECT *
FROM tops;

SELECT *
FROM sizes;

SELECT *
FROM outerwear;

SELECT *
FROM tops
CROSS JOIN sizes;

SELECT *
FROM outerwear
CROSS JOIN sizes;

-- 7. Union vs union all

-- View the tables

SELECT * FROM tops;
SELECT * FROM outerwear;

-- Union

SELECT * FROM tops
UNION
SELECT * FROM outerwear;

-- Union all

SELECT * FROM tops
UNION ALL
SELECT * FROM outerwear;


-- Union with different column names
SELECT * FROM happiness_scores;
SELECT * FROM happiness_scores_current;

-- Union 

SELECT YEAR, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024 as YEAR, country, ladder_score FROM happiness_scores_current
ORDER BY YEAR;