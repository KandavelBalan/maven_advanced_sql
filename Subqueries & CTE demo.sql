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
			
/* Return a country's happiness score for the year as well as
the average happiness score for the country across years */
       
/* Return years where the happiness score is a whole point
greater than the country's average happiness score */
