-- 1. Subqueries in the SELECT clause
SELECT * FROM happiness_scores;

-- Average happiness score
SELECT AVG(happiness_score) AVG_HPY_SCR FROM happiness_scores;

-- Happiness score deviation from the average
SELECT "year", country, happiness_score,
	(SELECT AVG(happiness_score) AVG_HPY_SCR FROM happiness_scores),
	happiness_score - (SELECT AVG(happiness_score) AVG_HPY_SCR FROM happiness_scores) DIFF_SCORE
FROM happiness_scores;

-- 2. Subqueries in the FROM clause
SELECT * FROM happiness_scores;

-- Average happiness score for each country
SELECT country, AVG(happiness_score)
FROM happiness_scores
GROUP BY country;

/* Return a country's happiness score for the year as well as
the average happiness score for the country across years */

SELECT "year", hs.country, hs.happiness_score,
c_hs.AVG_HS_BY_COUNTRY,
hs.happiness_score - c_hs.avg_hs_by_country DIFF_AVG
FROM happiness_scores hs
LEFT JOIN (SELECT country, AVG(happiness_score) AVG_HS_BY_COUNTRY
FROM happiness_scores
GROUP BY country) c_hs
ON hs.country = c_hs.country;
            
-- View one country
SELECT "year", hs.country, hs.happiness_score,
c_hs.AVG_HS_BY_COUNTRY,
hs.happiness_score - c_hs.avg_hs_by_country DIFF_AVG
FROM happiness_scores hs
LEFT JOIN (SELECT country, AVG(happiness_score) AVG_HS_BY_COUNTRY
FROM happiness_scores
GROUP BY country) c_hs
ON hs.country = c_hs.country
WHERE hs.country = 'India';

-- 3. Multiple subqueries

-- Return happiness scores for 2015 - 2024
            SELECT "year", country,happiness_score FROM happiness_scores
				UNION 
			SELECT 2024, country, ladder_score FROM happiness_scores_current;
			
/* Return a country's happiness score for the year as well as
the average happiness score for the country across years */
SELECT
	HS.YEAR,
	HS.COUNTRY,
	HS.HAPPINESS_SCORE,
	AVG_HS.AVG_HPY_SC,
	AVG_HS.AVG_HPY_SC - HS.HAPPINESS_SCORE DIFF_SCORE
FROM
	(
		SELECT
			"year",
			COUNTRY,
			HAPPINESS_SCORE
		FROM
			HAPPINESS_SCORES
		UNION
		SELECT
			2024,
			COUNTRY,
			LADDER_SCORE
		FROM
			HAPPINESS_SCORES_CURRENT
	) HS
	LEFT JOIN (
		SELECT
			HS.COUNTRY,
			AVG(HS.HAPPINESS_SCORE) AVG_HPY_SC
		FROM
			(
				SELECT
					"year",
					COUNTRY,
					HAPPINESS_SCORE
				FROM
					HAPPINESS_SCORES
				UNION
				SELECT
					2024,
					COUNTRY,
					LADDER_SCORE
				FROM
					HAPPINESS_SCORES_CURRENT
			) HS
		GROUP BY
			HS.COUNTRY
	) AVG_HS ON HS.COUNTRY = AVG_HS.COUNTRY;

/* Return years where the happiness score is a whole point
greater than the country's average happiness score */
SELECT
	TOTAL_HS.YEAR,
	TOTAL_HS.COUNTRY,
	TOTAL_HS.HAPPINESS_SCORE,
	TOTAL_HS.AVG_HPY_SC
FROM
	(
		SELECT
			HS.YEAR,
			HS.COUNTRY,
			HS.HAPPINESS_SCORE,
			AVG_HS.AVG_HPY_SC
		FROM
			(
				SELECT
					"year",
					COUNTRY,
					HAPPINESS_SCORE
				FROM
					HAPPINESS_SCORES
				UNION ALL
				SELECT
					2024,
					COUNTRY,
					LADDER_SCORE
				FROM
					HAPPINESS_SCORES_CURRENT
			) HS
			LEFT JOIN (
				SELECT
					HS.COUNTRY,
					AVG(HS.HAPPINESS_SCORE) AVG_HPY_SC
				FROM
					(
						SELECT
							"year",
							COUNTRY,
							HAPPINESS_SCORE
						FROM
							HAPPINESS_SCORES
						UNION ALL
						SELECT
							2024,
							COUNTRY,
							LADDER_SCORE
						FROM
							HAPPINESS_SCORES_CURRENT
					) HS
				GROUP BY
					HS.COUNTRY
			) AVG_HS ON HS.COUNTRY = AVG_HS.COUNTRY
	) TOTAL_HS
WHERE
	TOTAL_HS.HAPPINESS_SCORE > TOTAL_HS.AVG_HPY_SC + 1;

-- WITHOUT 2024 CALC AVERAGE
SELECT
	TOTAL_HS.YEAR,
	TOTAL_HS.COUNTRY,
	TOTAL_HS.HAPPINESS_SCORE,
	TOTAL_HS.AVG_HPY_SC
FROM
	(
		SELECT
			HS.YEAR,
			HS.COUNTRY,
			HS.HAPPINESS_SCORE,
			AVG_HS.AVG_HPY_SC
		FROM
			(
				SELECT
					"year",
					COUNTRY,
					HAPPINESS_SCORE
				FROM
					HAPPINESS_SCORES
				UNION ALL
				SELECT
					2024,
					COUNTRY,
					LADDER_SCORE
				FROM
					HAPPINESS_SCORES_CURRENT
			) HS
			LEFT JOIN (
				SELECT
					HS.COUNTRY,
					AVG(HS.HAPPINESS_SCORE) AVG_HPY_SC
				FROM
					HAPPINESS_SCORES HS
				GROUP BY
					HS.COUNTRY
			) AVG_HS ON HS.COUNTRY = AVG_HS.COUNTRY
	) TOTAL_HS
WHERE
	TOTAL_HS.HAPPINESS_SCORE > TOTAL_HS.AVG_HPY_SC + 1;

-- 4. Subqueries in the WHERE and HAVING clauses

-- Average happiness score
SELECT AVG(happiness_score) FROM happiness_scores;

-- Above average happiness scores (WHERE)

SELECT country,"year", happiness_score  FROM happiness_scores
WHERE happiness_score > (SELECT AVG(happiness_score) FROM happiness_scores);

-- Above average happiness scores for each region (HAVING)

SELECT region, AVG(happiness_score) AVG_HS  FROM happiness_scores
GROUP BY region
HAVING AVG(happiness_score) > (SELECT AVG(happiness_score) FROM happiness_scores);

-- 5. ANY vs ALL

SELECT * FROM happiness_scores; --2015 - 2023
SELECT * FROM happiness_scores_current; -- 2024

-- Scores that are greater than ANY 2024 scores
-- without any or all keywords
SELECT * FROM happiness_scores
WHERE happiness_score > (SELECT MIN(ladder_score) FROM happiness_scores_current);


SELECT * FROM happiness_scores
WHERE happiness_score > ANY(SELECT ladder_score FROM happiness_scores_current);

-- Scores that are greater than ALL 2024 scores

SELECT * FROM happiness_scores
WHERE happiness_score > ALL(SELECT ladder_score FROM happiness_scores_current);


-- 6. EXISTS

SELECT * FROM happiness_scores;
SELECT * FROM inflation_rates;

/* Return happiness scores of countries
that exist in the inflation rates table */
SELECT * FROM happiness_scores hs
WHERE EXISTS (
	SELECT ir.country_name
	FROM inflation_rates ir
	WHERE hs.country = ir.country_name
);

SELECT * FROM happiness_scores hs
WHERE EXISTS (
	SELECT 1
	FROM inflation_rates ir
	WHERE hs.country = ir.country_name
);

-- Alternative to EXISTS: INNER JOIN
SELECT * FROM happiness_scores hs
INNER JOIN inflation_rates ir
	ON hs.country = ir.country_name
	AND hs."year" = ir."year";

-- 7. CTEs: Readability

/* SUBQUERY: Return the happiness scores along with
   the average happiness score for each country */

SELECT "year", hs.country, hs.happiness_score,
c_hs.AVG_HS_BY_COUNTRY,
hs.happiness_score - c_hs.avg_hs_by_country DIFF_AVG
FROM happiness_scores hs
LEFT JOIN (SELECT country, AVG(happiness_score) AVG_HS_BY_COUNTRY
FROM happiness_scores
GROUP BY country) c_hs
ON hs.country = c_hs.country;

/* CTE: Return the happiness scores along with
   the average happiness score for each country */
WITH c_hs AS(SELECT country, 
					AVG(happiness_score) AVG_HS_BY_COUNTRY
			FROM happiness_scores
			GROUP BY country)
SELECT "year", hs.country, hs.happiness_score,
c_hs.AVG_HS_BY_COUNTRY,
hs.happiness_score - c_hs.avg_hs_by_country DIFF_AVG
FROM happiness_scores hs
LEFT JOIN  c_hs
ON hs.country = c_hs.country;

-- 8. CTEs: Reusability
        
-- SUBQUERY: Compare the happiness scores within each region in 2023
SELECT * FROM happiness_scores WHERE year = 2023;

SELECT	hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
FROM	happiness_scores hs1 INNER JOIN happiness_scores hs2
		ON hs1.region = hs2.region;
        
SELECT	hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
FROM	(SELECT * FROM happiness_scores WHERE year = 2023) hs1
		INNER JOIN
        (SELECT * FROM happiness_scores WHERE year = 2023) hs2
		ON hs1.region = hs2.region;

-- CTE: Compare the happiness scores within each region in 2023
WITH hs AS (SELECT * FROM happiness_scores WHERE year = 2023)

SELECT	hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
FROM	hs hs1 INNER JOIN hs hs2
		ON hs1.region = hs2.region
WHERE	hs1.country < hs2.country;

-- 8. CTEs: Reusability
        
-- SUBQUERY: Compare the happiness scores within each region in 2023
SELECT * FROM happiness_scores WHERE year = 2023;

SELECT hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
FROM happiness_scores hs1
INNER JOIN happiness_scores hs2 
	ON hs1.region = hs2.region
WHERE hs1.year = 2023;
        
SELECT hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score 
FROM (SELECT * FROM happiness_scores WHERE year = 2023) hs1
INNER JOIN (SELECT * FROM happiness_scores WHERE year = 2023) hs2 
			ON hs1.region = hs2.region;

-- CTE: Compare the happiness scores within each region in 2023

WITH hs AS(
			SELECT * FROM happiness_scores WHERE year = 2023
)
SELECT hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
		FROM hs hs1
	INNER JOIN hs hs2 ON hs1.region = hs2.region
	WHERE hs1.country < hs2.country;

-- 9. Multiple CTEs

-- Step 1: Compare 2023 vs 2024 happiness scores side by side
WITH hs_2023 AS( SELECT * FROM happiness_scores 
				  WHERE year = 2023),
	 hs_2024 AS( SELECT * FROM happiness_scores_current)
SELECT hs_2023.country, hs_2023.happiness_score hs_2023_score,
hs_2024.ladder_score hs_2024_score
FROM hs_2023 
INNER JOIN hs_2024 on hs_2023.country = hs_2024.country;

-- Step 2: Return the countries where the score increased

WITH hs_2023 AS( SELECT * FROM happiness_scores 
				  WHERE year = 2023),
	 hs_2024 AS( SELECT * FROM happiness_scores_current)
SELECT country, hs_2023_score, hs_2024_score
FROM
(SELECT hs_2023.country, hs_2023.happiness_score hs_2023_score,
hs_2024.ladder_score hs_2024_score
FROM hs_2023 
INNER JOIN hs_2024 on hs_2023.country = hs_2024.country) hs_2023_2024
WHERE hs_2024_score > hs_2023_score;

-- Alternative: CTEs only

WITH hs_2023 AS( SELECT * FROM happiness_scores 
				  WHERE year = 2023),
	 hs_2024 AS( SELECT * FROM happiness_scores_current),
	 hs_2023_2024 AS(SELECT hs_2023.country, hs_2023.happiness_score hs_2023_score,
hs_2024.ladder_score hs_2024_score
FROM hs_2023 
INNER JOIN hs_2024 on hs_2023.country = hs_2024.country)
SELECT country, hs_2023_score, hs_2024_score
FROM
 hs_2023_2024
WHERE hs_2024_score > hs_2023_score

-- Step 3: Return the countries where the score decreased

WITH hs_2023 AS( SELECT * FROM happiness_scores 
				  WHERE year = 2023),
	 hs_2024 AS( SELECT * FROM happiness_scores_current),
	 hs_2023_2024 AS(SELECT hs_2023.country, hs_2023.happiness_score hs_2023_score,
hs_2024.ladder_score hs_2024_score
FROM hs_2023 
INNER JOIN hs_2024 on hs_2023.country = hs_2024.country)
SELECT country, hs_2023_score, hs_2024_score
FROM
 hs_2023_2024
WHERE hs_2024_score < hs_2023_score;

-- 10. Recursive CTEs

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
    

-- Example 1: Generating sequences
SELECT * FROM stock_prices;


-- Generate a column of dates
WITH RECURSIVE dates(dt) AS(
	SELECT TIMESTAMP '2024-11-01' dt 
	UNION
	SELECT DT + INTERVAL '1 DAY'
	FROM dates
	WHERE DT < TIMESTAMP '2024-11-06'
)
SELECT DT
FROM dates;

WITH RECURSIVE dates(dt) AS(
	SELECT DATE '2024-11-01' dt 
	UNION
	SELECT (DT + INTERVAL '1 DAY') :: DATE
	FROM dates
	WHERE DT < DATE '2024-11-06'
)
SELECT DT
FROM dates;

-- Include the original prices

WITH RECURSIVE dates(dt) AS(
	SELECT DATE '2024-11-01' dt 
	UNION
	SELECT (DT + INTERVAL '1 DAY') :: DATE
	FROM dates
	WHERE DT < DATE '2024-11-06'
)
SELECT DT,
		sp.price
FROM dates
LEFT JOIN stock_prices sp on dates.dt = sp.date
ORDER BY DT;

-- Example 2: Working with hierachical data

SELECT  * FROM employees;

-- Return the reporting chain for each employee
WITH RECURSIVE eh AS(
	SELECT employee_id, employee_name, manager_id, (employee_name)::text AS hier
	FROM employees
	WHERE manager_id IS NULL
	UNION All
	SELECT e.employee_id, e.employee_name, e.manager_id,CONCAT(eh.hier,' > ', e.employee_name)::text hier
	FROM employees e
	INNER JOIN eh ON e.manager_id = eh.employee_id
)
SELECT * 
FROM eh;
-- 11. Subquery vs CTE vs Temp Table vs View

-- Subquery
SELECT * FROM

(SELECT	year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT	2024, country, ladder_score FROM happiness_scores_current) AS my_subquery;

-- CTE
WITH my_cte AS (SELECT	year, country, happiness_score FROM happiness_scores
				UNION ALL
				SELECT	2024, country, ladder_score FROM happiness_scores_current)
                
SELECT * FROM my_cte;

-- Temporary table
CREATE TEMPORARY TABLE my_temp_table AS
SELECT	year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT	2024, country, ladder_score FROM happiness_scores_current;

SELECT * FROM my_temp_table;

-- View
CREATE VIEW my_view AS
SELECT	year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT	2024, country, ladder_score FROM happiness_scores_current;

SELECT * FROM my_view;