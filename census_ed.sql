--How many public high schools are in each zip code?
--In each state?

SELECT zip_code AS 'Zip Code',
	COUNT(*) AS 'Number of	Public High Schools'
FROM public_hs_data
GROUP BY 1;

SELECT state_code AS 'State',
	COUNT(*) AS 'Number of Public High Schools'
FROM public_hs_data
GROUP BY 1;

SELECT 
	city AS 'City',
	state_code AS 'State',
	zip_code AS 'Zip Code',
	CASE 
		WHEN locale_code BETWEEN 11 AND 13 THEN 'City'
		WHEN locale_code BETWEEN 21 AND 23 THEN 'Suburb'
		WHEN locale_code BETWEEN 31 AND 33 THEN 'Town'
		WHEN locale_code BETWEEN 41 AND 43 THEN 'Rural'
	END AS 'Community',
	
	CASE	
		WHEN locale_code <= 23 THEN
		CASE substr(locale_code,2,1)
			WHEN '1' THEN 'Large'
			WHEN '2' THEN 'Midsize'
			WHEN '3' THEN 'Small'
		END 
		
		WHEN locale_code >= 31 THEN
		CASE substr(locale_code,2,1)	
			WHEN '1' THEN 'Fringe'
			WHEN '2' THEN 'Distant'
			WHEN '3' THEN 'Remote'
		END 
	END AS 'Size'
FROM public_hs_data;


--What is the minimum, maximum, and average median_household_income of the nation? 
--for each state?

 SELECT 
	MIN(median_household_income) AS 'Minimum Median Income',
	MAX(median_household_income) AS 'Maximum Median Income',
	ROUND(AVG(median_household_income),0) AS 'Average Median Income'
FROM census_data
WHERE median_household_income != 'NULL';

SELECT 
	state_code AS 'State',
	MIN(median_household_income) AS 'Minimum Median Income',
	MAX(median_household_income) AS 'Maximum Median Income',
	ROUND(AVG(median_household_income),0) AS 'Average Median Income'
FROM census_data
WHERE median_household_income != 'NULL'
GROUP BY 1;


--Do characteristics of the zip-code area, such as median household income, influence students’ performance in high school?

SELECT
	CASE 
		WHEN median_household_income <50000 THEN 'Lower'
		WHEN median_household_income BETWEEN 50000 AND 100000 THEN 'Middle'
		WHEN median_household_income >100000 THEN 'Upper'
	END 'Income Range',
	ROUND(AVG(pct_proficient_math),2) AS 'Average Math Proficiency',
	ROUND(AVG(pct_proficient_reading),2) AS 'Average Reading Proficiency'
FROM census_data
JOIN public_hs_data
	ON census_data.zip_code = public_hs_data.zip_code
GROUP BY 1
ORDER BY 2;


--On average, do students perform better on the math or reading exam? 
--Find the number of states where students do better on the math exam, and vice versa

WITH avg_exams AS(
	SELECT 
		state_code 'State',
		ROUND(AVG(pct_proficient_math),2) 'Average Math Score',
		ROUND(AVG(pct_proficient_reading),2) 'Average Reading Score',
		CASE
			WHEN AVG(pct_proficient_math) > AVG(pct_proficient_reading) THEN 'Math'
			WHEN AVG(pct_proficient_math) < AVG(pct_proficient_reading) THEN 'Reading'
			ELSE 'No Exam Data'
		END 'higher'
	FROM public_hs_data
	GROUP BY 1
)
SELECT 
	higher 'Exam Subject',
	COUNT(higher) 'Number of States Where Subject Performed Highest'
FROM avg_exams
GROUP BY 1;


--What is the average proficiency on state assessment exams for each zip code, and how do they compare to other zip codes in the same state?

WITH state_stats AS(
	SELECT 
		state_code 'state',
		ROUND(MIN(pct_proficient_math),2) 'min_ms',
		ROUND(MAX(pct_proficient_math),2) 'max_ms',
		ROUND(AVG(pct_proficient_math),2) 'avg_ms',
		ROUND(MIN(pct_proficient_reading),2) 'min_rs',
		ROUND(MAX(pct_proficient_reading),2) 'max_rs',
		ROUND(AVG(pct_proficient_reading),2) 'avg_rs'
	FROM public_hs_data
	WHERE pct_proficient_math != 'NULL' AND pct_proficient_reading != 'NULL'
	GROUP BY 1
)
SELECT 
	zip_code 'Zip Code',
	state_code 'State',
	ROUND(pct_proficient_math,2) 'Zip-Code Math Score',
	state_stats.avg_ms 'Average State Math Score',
	state_stats.max_ms 'Maximum State Math Score',
	state_stats.min_ms 'Minimum State Math Score',
	ROUND(pct_proficient_reading,2) 'Zip-Code Reading Score',	
	state_stats.avg_rs 'Average State Reading Score',
	state_stats.max_rs 'Maximum State Reading Score',
	state_stats.min_rs 'Minimum State Reading Score'
FROM state_stats
LEFT JOIN public_hs_data
	ON state_stats.State = public_hs_data.state_code
GROUP BY 1
ORDER BY 1;