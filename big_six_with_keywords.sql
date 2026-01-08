select current_database();


-- 1. View the students table
select * from students;

-- 2. The big 6 
SELECT grade_level, AVG(gpa) avg_gpa
FROM students
WHERE school_lunch = 'Yes'
GROUP BY grade_level
HAVING AVG(gpa) > 3
ORDER BY grade_level;

-- 3. Common Keywords

-- i) DISTINCT
SELECT DISTINCT grade_level AS GRADE_LEVEL
FROM students;

-- ii) COUNT

SELECT COUNT(DISTINCT grade_level) AS GRADE_LEVEL
FROM students;

-- iii) MAX & MIN

SELECT MAX(gpa) MAX_GPA
,MIN(gpa) MIN_GPA
,MAX(gpa) - MIN(gpa) AS RANGE
FROM students;

-- iv) AND
SELECT *
FROM students
WHERE grade_level >10 
AND school_lunch = 'No';

-- v) IN
SELECT * 
FROM students
WHERE grade_level IN (9,10);

-- vi) IS NULL
SELECT * 
FROM students
WHERE email IS NULL;

-- vii) LIKE
SELECT *
FROM students
WHERE email LIKE '%com%';

-- viii) ORDER BY
SELECT *
FROM students
ORDER BY id DESC;

-- ix) LIMIT
SELECT * 
FROM students
LIMIT 5;

-- x) CASE STATEMENT
SELECT student_name, 
grade_level,
CASE WHEN grade_level = 9 THEN 'First year'
	 WHEN grade_level = 10 THEN 'Sophomore'
	 WHEN grade_level = 11 THEN 'Junior'
	 ELSE 'Senior' END Stu_Class
FROM students;