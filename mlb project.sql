-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables

SELECT * FROM players;

SELECT * FROM schools;

select * from school_details;


-- 2. In each decade, how many schools were there that produced players?

	SELECT floor(yearid/10) * 10 as decade , count( distinct schoolid) schoolcount
	FROM schools
	GROUP BY floor(yearid/10) * 10
	ORDER BY floor(yearid/10)*10;

-- 3. What are the names of the top 5 schools that produced the most players?

SELECT sd.name_full , count( playerid) most_players
FROM Schools s
JOIN school_details sd ON s.schoolid = sd.schoolid
GROUP BY sd.name_full
ORDER BY most_players desc
LIMIT 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?

WITH yearcte as(SELECT floor(s.yearid/10) * 10 as decade ,  s.schoolid, sd.name_full, count(distinct s.playerid) count_player 
					FROM schools s
				JOIN school_details sd ON s.schoolid = sd.schoolid
					GROUP BY floor(s.yearid/10) * 10, s.schoolid, sd.name_full)
	, TS as(SELECT decade, name_full, count_player, dense_rank() over(PARTITION BY decade ORDER BY count_player desc) top_school
					FROM yearcte)
Select decade, name_full, count_player
From ts
Where top_school <= 3
Order by decade desc,count_player;

-- PART II: SALARY ANALYSIS

-- TASK 1: View the salaries table
SELECT * FROM salaries
WHERE playerid = 'abbotky01';

-- TASK 2: Return the top 20% of teams in terms of average annual spending [Window Functions]

WITH avg_sp AS(SELECT Yearid, teamid, round(Avg(salary),2) avg_annu_sp 
					FROM salaries
					GROUP BY Yearid, teamid)
	,avg_sp_p AS(SELECT yearid, teamid, avg_annu_sp, 
			   		NTILE(5) OVER(PARTITION BY yearid ORDER BY avg_annu_sp DESC) avg_sp_per
					FROM avg_sp
					)
SELECT yearid, teamid, avg_annu_sp
FROM avg_sp_p
WHERE avg_sp_per = 1
ORDER BY yearid DESC;

WITH tol_sp AS(SELECT Yearid, teamid, SUM(salary) total_sp 
					FROM salaries
					GROUP BY Yearid, teamid)
	,avg_sp_p AS(SELECT  teamid, avg(total_sp) avg_tol_sp, 
			   		NTILE(5) OVER( ORDER BY avg(total_sp) DESC) avg_sp_per
					FROM tol_sp
					GROUP BY teamid
					)
SELECT  teamid, round(avg_tol_sp/1000000,2)
FROM avg_sp_p
WHERE avg_sp_per = 1
ORDER BY avg_tol_sp DESC;


-- TASK 3: For each team, show the cumulative sum of spending over the years [Rolling Calculations]

SELECT yearid, teamid, sum(sum(salary)) over(partition by teamid order by yearid)
FROM salaries
GROUP BY yearid, teamid;

SELECT DISTINCT yearid, teamid, sum(salary) over(partition by teamid order by yearid)
FROM salaries
ORDER BY teamid, yearid;

-- TASK 4: Return the first year that each team's cumulative spending surpassed 1 billion [Min / Max Value Filtering]

WITH cum_sp AS ( SELECT yearid, teamid, sum(sum(salary)) over(partition by teamid order by yearid) cum_spend
					FROM salaries
					GROUP BY yearid, teamid)
	,fB AS		(SELECT teamid,  min(cum_spend) fir_bil
					FROM cum_sp
					WHERE floor(cum_spend/1000000000) >= 1
					GROUP BY teamid)
SELECT cum_sp.teamid, cum_sp.yearid, cum_sp.cum_spend
FROM cum_sp
JOIN fb ON cum_sp.teamid = fb.teamid
		AND cum_sp.cum_spend = fb.fir_bil;

-- PART III: PLAYER CAREER ANALYSIS

-- TASK 1: View the players table and find the number of players in the table
SELECT * FROM players;
SELECT COUNT(*) FROM players;

-- TASK 2: For each player, calculate their age at their first (debut) game, their last game,
-- and their career length (all in years). Sort from longest career to shortest career. [Datetime Functions]

SELECT playerid, 
FLOOR((debut - to_date(concat_ws('-',cast(birthyear as text),cast(birthmonth as text),cast(birthday as text)),'YYYY-MM-DD'))/365.25) age_fg,
FLOOR((finalgame - to_date(concat_ws('-',cast(birthyear as text),cast(birthmonth as text),cast(birthday as text)),'YYYY-MM-DD'))/365.25) age_lg,
 COALESCE(FLOOR((finalgame - debut)/365.25),0) career_length
FROM players
ORDER BY career_length desc;


-- TASK 3: What team did each player play on for their starting and ending years? [Joins]

WITH pl_yr AS(	SELECT playerid, MIN(Yearid) start_yr, MAX(yearid) end_yr
				FROM SALARIES
				GROUP BY playerid)
SELECT s.playerid, SY.teamid start_team, EY.teamid end_team 
FROM pl_yr S
LEFT JOIN salaries SY ON S.playerid = SY.playerid
	AND SY.yearid = S.start_yr
LEFT JOIN salaries EY ON S.playerid = EY.playerid
	AND EY.yearid = S.end_yr
ORDER BY s.playerid;

-- TASK 4: How many players started and ended on the same team and also played for over a decade? [Basics]


WITH pl_yr AS(	SELECT playerid, MIN(Yearid) start_yr, MAX(yearid) end_yr
				FROM SALARIES
				GROUP BY playerid)
	,pl_tm  AS(	SELECT s.playerid, SY.teamid start_team, EY.teamid end_team 
				FROM pl_yr S
				LEFT JOIN salaries SY ON S.playerid = SY.playerid
					AND SY.yearid = S.start_yr
				LEFT JOIN salaries EY ON S.playerid = EY.playerid
					AND EY.yearid = S.end_yr
				ORDER BY s.playerid)
SELECT tm.playerid, p.* FROM 
pl_tm tm
LEFT JOIN players p ON tm.playerid = p.playerid
WHERE start_team = end_team
and cast(extract(year from finalgame) - extract( year from debut) as integer) >=10;

-- PART IV: PLAYER COMPARISON ANALYSIS

-- TASK 1: View the players table
SELECT distinct bats FROM players;

-- TASK 2: Which players have the same birthday? Hint: Look into GROUP_CONCAT / LISTAGG / STRING_AGG [String Functions]
WITH bd AS(
SELECT  namegiven,
-- to_date(concat(birthyear,'-',birthmonth,'-',birthday),'yyyy-mm-dd'),
	to_date(concat_ws('-',cast(birthyear as text),cast(birthmonth as text),cast(birthday as text)),'YYYY-MM-DD') birthday
FROM players
WHERE birthyear between 1980 and 1990)
SELECT birthday, string_agg(namegiven,', ')
FROM bd
GROUP BY birthday;

-- TASK 3: Create a summary table that shows for each team, what percent of players bat right, left and both [Pivoting]

SELECT s.teamid,  count(p.playerid),
		round(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / count(p.playerid) ,5)  "lefthand",
		SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / count(p.playerid) "righthand",
		SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / count(p.playerid) "bothhand"
FROM Salaries s
JOIN players p ON s.playerid = p.playerid
GROUP BY s.teamid
ORDER BY s.teamid;

-- TASK 4: How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference? [Window Functions]

WITH hw AS(
		SELECT FLOOR((extract(YEAR FROM debut)/10))*10 AS decade,
		ROUND(AVG(weight)) avg_weight, ROUND(AVG(height)) avg_height
		FROM players
		GROUP BY FLOOR((extract(YEAR FROM debut)/10))*10)
SELECT 	decade, 
		avg_weight - lag(avg_weight) over(order by decade) diff_weight,
		avg_height - lag(avg_height) over(order by decade) diff_height
FROM hw;