-- ASSIGNMENT 1: Duplicate values

-- View the students data

SELECT * FROM students;

-- Create a column that counts the number of times a student appears in the table

SELECT student_name, count(*)
FROM students
group by student_name
having count(*) > 1;

-- Return student ids, names and emails, excluding duplicates students

SELECT * 
FROM (SELECT id, student_name, email,
		Row_number() over(partition by student_name order by id desc) row_num
FROM students) dup_stu
Where row_num = 1;

-- ASSIGNMENT 2: Min / max value filtering

-- View the students and student grades tables

Select * from students;

Select * from student_grades;

-- For each student, return the classes they took and their final grades

Select  sg.student_id, s.student_name, sg.class_name, sg.final_grade
From student_grades sg
Join students s on sg.student_id = s.id
where student_id = 2
order by sg.student_id;
        
-- Return each student's top grade and corresponding class
WITH top_grade as(
			Select  sg.student_id, max(sg.final_grade) top_grade
			From student_grades sg
			group by sg.student_id)
Select sg.student_id, s.student_name, sg.class_name, sg.final_grade
From student_grades sg
Join students s on sg.student_id = s.id
Join top_grade tg on sg.student_id = tg.student_id
		and sg.final_grade = tg.top_grade
order by sg.student_id;

Select *
from(
Select sg.student_id, s.student_name, sg.class_name, sg.final_grade,
		DENSE_RANK() OVER(Partition by student_id order by sg.final_grade desc) row_num
From student_grades sg
Join students s on sg.student_id = s.id
Where sg.final_grade is not null) top_rank
where row_num = 1;
                    
-- ASSIGNMENT 3: Pivoting

-- Combine the students and student grades tables

SELECT * FROM students;
SELECT * FROM student_grades;

-- View only the columns of interest

SELECT id,
	student_name, 
	grade_level,
	CASE WHEN grade_level = 9 THEN 'First year'
		 WHEN grade_level = 10 THEN 'Sophomore'
		 WHEN grade_level = 11 THEN 'Junior'
		 ELSE 'Senior' END Stu_Class,
	sg.department,
	sg.final_grade
FROM students s
JOIN student_grades sg on s.id = sg.student_id;
        
-- Pivot the grade_level column

WITH year_cte AS(SELECT id,
	student_name, 
	grade_level,
	CASE WHEN grade_level = 9 THEN 'First year'
		 WHEN grade_level = 10 THEN 'Sophomore'
		 WHEN grade_level = 11 THEN 'Junior'
		 ELSE 'Senior' END Stu_Class,
	sg.department,
	sg.final_grade
FROM students s
JOIN student_grades sg on s.id = sg.student_id)
SELECT 	CASE WHEN stu_class = 'First year' THEN 1  END "first Year", 
		CASE WHEN stu_class = 'Sophomore' THEN 1  END "Sophomore",
		CASE WHEN stu_class = 'Junior' THEN 1  END "Junior",
		CASE WHEN stu_class = 'Senior' THEN 1  END "Senior"
FROM year_cte; 
	   
-- Update the values to be final grades

WITH year_cte AS(SELECT id,
	student_name, 
	grade_level,
	CASE WHEN grade_level = 9 THEN 'First year'
		 WHEN grade_level = 10 THEN 'Sophomore'
		 WHEN grade_level = 11 THEN 'Junior'
		 ELSE 'Senior' END Stu_Class,
	sg.department,
	sg.final_grade
FROM students s
JOIN student_grades sg on s.id = sg.student_id)
SELECT department,
		FLOOR(AVG(CASE WHEN stu_class = 'First year' THEN final_grade ELSE 0 END)) "first Year", 
		FLOOR(AVG(CASE WHEN stu_class = 'Sophomore' THEN final_grade ELSE 0 END)) "Sophomore",
		FLOOR(AVG(CASE WHEN stu_class = 'Junior' THEN final_grade ELSE 0 END)) "Junior",
		FLOOR(AVG(CASE WHEN stu_class = 'Senior' THEN final_grade ELSE 0 END)) "Senior"
FROM year_cte
GROUP BY department
ORDER BY department;

-- Create the final summary table

WITH year_cte AS(SELECT id,
	student_name, 
	grade_level,
	CASE WHEN grade_level = 9 THEN 'First year'
		 WHEN grade_level = 10 THEN 'Sophomore'
		 WHEN grade_level = 11 THEN 'Junior'
		 ELSE 'Senior' END Stu_Class,
	sg.department,
	sg.final_grade
FROM students s
JOIN student_grades sg on s.id = sg.student_id)
SELECT department,
		FLOOR(AVG(CASE WHEN stu_class = 'First year' THEN final_grade  END)) "first Year", 
		FLOOR(AVG(CASE WHEN stu_class = 'Sophomore' THEN final_grade END)) "Sophomore",
		FLOOR(AVG(CASE WHEN stu_class = 'Junior' THEN final_grade END)) "Junior",
		FLOOR(AVG(CASE WHEN stu_class = 'Senior' THEN final_grade END)) "Senior"
FROM year_cte
GROUP BY department
ORDER BY department;

-- ASSIGNMENT 4: Rolling calculations

-- Calculate the total sales each month

	SELECT to_char(o.order_date,'yyyy-mm') order_month, SUM(o.units * p.unit_price) total_sales
				FROM orders o
				JOIN products p ON o.product_id = p.product_id
				GROUP BY TO_CHAR(o.order_date,'yyyy-mm')
				ORDER BY TO_CHAR(o.order_date,'yyyy-mm');

-- Add on the cumulative sum and 6 month moving average

	WITH ts AS(SELECT to_char(o.order_date,'yyyy-mm') order_month, SUM(o.units * p.unit_price) total_sales
				FROM orders o
				JOIN products p ON o.product_id = p.product_id
				GROUP BY TO_CHAR(o.order_date,'yyyy-mm')
				ORDER BY TO_CHAR(o.order_date,'yyyy-mm'))
	SELECT order_month, total_sales, 
		sum(total_sales) over(order by order_month) cum_sales,
		AVG(total_sales) over(order by order_month 
								rows between 5 preceding and current row) month_cum_sales
	FROM ts;
