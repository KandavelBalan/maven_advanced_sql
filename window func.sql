
-- 1. Window function basics

-- Return all row numbers

SELECT country, "year", row_number() over() row_num
FROM happiness_scores;

-- Return all row numbers within each window

SELECT country, "year", ROW_NUMBER() OVER(PARTITION BY country ORDER BY "year") row_num
FROM happiness_scores;

-- Return all row numbers within each window
-- where the rows are ordered by happiness score

SELECT country, "year", happiness_score, ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score) row_num
FROM happiness_scores;

-- Return all row numbers within each window
-- where the rows are ordered by happiness score descending

SELECT country, "year", happiness_score, ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score DESC) row_num
FROM happiness_scores;

-- 2. ROW_NUMBER vs RANK vs DENSE_RANK

CREATE TABLE baby_girl_names (
    name VARCHAR(50),
    babies INT);

INSERT INTO baby_girl_names (name, babies) VALUES
	('Olivia', 99),
	('Emma', 80),
	('Charlotte', 80),
	('Amelia', 75),
	('Sophia', 72),
	('Isabella', 70),
	('Ava', 70),
	('Mia', 64);
    
-- View the table

SELECT * FROM baby_girl_names;

-- Compare ROW_NUMBER vs RANK vs DENSE_RANK

SELECT "name", babies,
	ROW_NUMBER() OVER(ORDER BY babies) row_num,
	RANK() OVER(ORDER BY babies) rank_num,
	DENSE_RANK() OVER(ORDER BY babies) dense_rank_num
FROM baby_girl_names;

SELECT "name", babies,
	ROW_NUMBER() OVER(ORDER BY babies DESC) row_num,
	RANK() OVER(ORDER BY babies DESC) rank_num,
	DENSE_RANK() OVER(ORDER BY babies DESC) dense_rank_num
FROM baby_girl_names;

-- 3. FIRST_VALUE, LAST VALUE & NTH_VALUE
CREATE TABLE baby_names (
    gender VARCHAR(10),
    name VARCHAR(50),
    babies INT);

INSERT INTO baby_names (gender, name, babies) VALUES
	('Female', 'Charlotte', 80),
	('Female', 'Emma', 82),
	('Female', 'Olivia', 99),
	('Male', 'James', 85),
	('Male', 'Liam', 110),
	('Male', 'Noah', 95);
    
-- View the table
SELECT * FROM baby_names;
    
-- Return the first name in each window

SELECT gender, "name", babies, 
	FIRST_VALUE("name") OVER(PARTITION BY gender ORDER BY babies DESC) top_name
FROM baby_names;

-- Return the top name for each gender

SELECT * FROM
(SELECT gender, "name", babies, 
	FIRST_VALUE("name") OVER(PARTITION BY gender ORDER BY babies DESC) top_name
FROM baby_names)
WHERE "name" = top_name;

-- CTE alternative

WITH top_nm AS (
SELECT gender, "name", babies, 
	FIRST_VALUE("name") OVER(PARTITION BY gender ORDER BY babies DESC) top_name
FROM baby_names)
SELECT * 
FROM top_nm
WHERE "name" = top_name;

-- Return the second name in each window

SELECT gender, "name", babies, 
	NTH_VALUE("name",2) OVER(PARTITION BY gender ORDER BY babies DESC) top_name
FROM baby_names;

-- Return the 2nd most popular name for each gender

WITH sec_nm AS (
SELECT gender, "name", babies, 
	NTH_VALUE("name",2) OVER(PARTITION BY gender ORDER BY babies DESC) sec_name
FROM baby_names)
SELECT * 
FROM sec_nm
WHERE "name" = sec_name;

-- Alternative using ROW_NUMBER

SELECT gender, "name", babies, 
	ROW_NUMBER() OVER(PARTITION BY gender ORDER BY babies DESC) row_num
FROM baby_names;

-- Number all the rows within each window

WITH nth_name AS(
SELECT gender, "name", babies, 
	ROW_NUMBER() OVER(PARTITION BY gender ORDER BY babies DESC) row_num
FROM baby_names)
SELECT *
FROM nth_name 
WHERE row_num = 2;

-- Return the top 2 most popular names for each gender

WITH nth_name AS(
SELECT gender, "name", babies, 
	ROW_NUMBER() OVER(PARTITION BY gender ORDER BY babies DESC) row_num
FROM baby_names)
SELECT *
FROM nth_name 
WHERE row_num <= 2;

-- 4. LEAD & LAG

-- Return the prior year's happiness score

SELECT 	country, "year", happiness_score, 
		LAG(happiness_score) OVER(PARTITION BY country ORDER BY "year") prior_happiness_score
FROM happiness_scores;

SELECT 	country, "year", happiness_score, 
		LEAD(happiness_score) OVER(PARTITION BY country ORDER BY "year") next_happiness_score
FROM happiness_scores;

-- Return the difference between yearly scores

WITH prev_year AS(
SELECT 	country, "year", happiness_score, 
		LAG(happiness_score) OVER(PARTITION BY country ORDER BY "year") prior_happiness_score
FROM happiness_scores)
SELECT country, "year", happiness_score, prior_happiness_score,
happiness_score - prior_happiness_score diff_score
FROM prev_year;

WITH next_year AS(
SELECT 	country, "year", happiness_score, 
		LEAD(happiness_score) OVER(PARTITION BY country ORDER BY "year") next_happiness_score
FROM happiness_scores)
SELECT country, "year", happiness_score, next_happiness_score,
next_happiness_score - happiness_score diff_score
FROM next_year;

-- 5. NTILE

-- Add a percentile to each row of data

SELECT 	country, "year", happiness_score
		,NTILE(10) OVER(PARTITION BY country ORDER BY happiness_score DESC) percentile_score
FROM happiness_scores;

SELECT region, country, happiness_score
		,NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC) percentile_score
FROM happiness_scores
WHERE "year" = 2023
ORDER BY region, percentile_score;

-- For each region, return the top 25% of countries, in terms of happiness score

WITH pct_score AS(
		SELECT region, country, happiness_score
				,NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC) percentile_score
		FROM happiness_scores
		WHERE "year" = 2023
		ORDER BY region, percentile_score
)
SELECT region, country, happiness_score
FROM pct_score
WHERE percentile_score = 1;