--- SQL PROJECT

/* 1. CREATING MY DATABASE - I created my database and named it 'PROJECT' and ensured the database was selected.
*/
CREATE DATABASE PROJECT;
USE PROJECT;

/* 2. IMPORTING THE DATASET - The 3 different dataset namely "forest_area", "land_area", and "regions" were imported and selected to view the table layout, content, and identify NULL values.
*/
SELECT * FROM forest_area;
SELECT * FROM land_area;
SELECT * FROM regions;

/* 3. UPDATING THE TABLE - The values in the columns "forest_area_sqkm" and "total_area_sq_mi" were rounded to 2 decimal places and the tables updated.
*/
UPDATE forest_area
SET forest_area_sqkm = ROUND(forest_area_sqkm, 2);

UPDATE land_area
SET total_area_sq_mi = ROUND(total_area_sq_mi, 2);

SELECT * FROM forest_area;
SELECT * FROM land_area;

/* 4. CHECKING FOR NULL VALUES - Checking for NULL values in the forest_area and land_area tables, specifically the numerical columns.
*/
SELECT  * FROM forest_area WHERE forest_area_sqkm IS NULL; 
SELECT  * FROM land_area WHERE total_area_sq_mi IS NULL; 
 
 /* 5. REPLACING NULL VALUES - I calculated the average forest and land area and used the average value to replace the NULL values in the columns. Checked the columns again to be sure this executed correctly.
 */
SELECT ROUND(AVG(forest_area_sqkm), 2) FROM forest_area;
SELECT ROUND(AVG(total_area_sq_mi), 2) FROM land_area;

UPDATE forest_area SET forest_area_sqkm = 391051.84 WHERE forest_area_sqkm IS NULL;
UPDATE land_area SET total_area_sq_mi = 457095.35 WHERE total_area_sq_mi IS NULL;

SELECT  * FROM forest_area WHERE forest_area_sqkm IS NULL; 
SELECT  * FROM land_area WHERE total_area_sq_mi IS NULL; 

/* SELECT DISTINCT COALESCE(forest_area_sqkm, NULL,391051.84) FROM forest_area WHERE forest_area_sqkm IS NULL;
SELECT DISTINCT COALESCE(total_area_sq_mi, NULL, 457095.35) FROM land_area WHERE total_area_sq_mi IS NULL;*/

/* Deforestation Project Questions.*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 1: What are the total number of countries involved in deforestation?
SELECT DISTINCT COUNT(country_name) FROM regions;
SELECT DISTINCT country_name FROM regions;


-- Question 2: Show the income groups of countries having total area ranging from 75,000 to 150,000 square meter?
SELECT country_name, income_group FROM regions R JOIN land_area L ON R.country_name = L.country_name
WHERE total_area_sq_mi BETWEEN 75000 AND 150000;

/* the above syntax throws an "ambiguous column name" error because the column "country_name" appears in both tables with the exact same title which confuses the database engine. 
To fix this, I had to qualify the the "country_name" column with the table name or Alias*/

SELECT R.country_name, income_group, total_area_sq_mi FROM regions R JOIN land_area L ON R.country_name = L.country_name
WHERE total_area_sq_mi BETWEEN 75000 AND 150000;

/* I included the total_area_sq_mi column to crosscheck the result of the query*/


-- Question 3: Calculate average area in square miles for countries in the 'upper middle income region'. Compare the result with the rest of the income categories.
SELECT R.country_name, income_group, ROUND(AVG(total_area_sq_mi), 2) AS AVG_AREA FROM regions R JOIN land_area L on R.country_name = L.country_name
GROUP BY R.country_name, region, income_group HAVING income_group = 'Upper middle income'
ORDER BY AVG_AREA DESC;

-- comparing the result to the other income groups by selecting income groups that are NOT in the 'upper middle income' category
SELECT R.country_name, income_group, ROUND(AVG(total_area_sq_mi), 2) AS AVG_AREA FROM regions R JOIN land_area L on R.country_name = L.country_name
GROUP BY R.country_name, region, income_group HAVING income_group != 'Upper middle income'
ORDER BY AVG_AREA DESC;


-- Question 4: Determine the total forest area in square km for countries in the 'high income' group. Compare result with the rest of the income categories.
SELECT F.country_name, income_group, SUM(forest_area_sqkm) AS TOTAL_AREA FROM forest_area F JOIN regions R ON F.country_code = R.country_code 
GROUP BY F.country_name, income_group HAVING income_group = 'High income' ORDER BY TOTAL_AREA DESC;

SELECT F.country_name, income_group, SUM(forest_area_sqkm) AS TOTAL_AREA FROM forest_area F JOIN regions R ON F.country_code = R.country_code 
GROUP BY F.country_name, income_group HAVING income_group <> 'High income' ORDER BY TOTAL_AREA DESC;


-- Question 5: Show countries from each region(continent) having the highest total forest areas. This can be tackled in two ways:
-- Using subqueries
SELECT * FROM
(SELECT R.country_name, region, ROUND(SUM(forest_area_sqkm), 2) AS TOTAL_FOREST_AREA, DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(forest_area_sqkm) DESC) HIGHEST_FOREST_RANK 
FROM regions R JOIN forest_area F ON R.country_name = F.country_name GROUP BY R.country_name, region) RankedForests
WHERE HIGHEST_FOREST_RANK = 1;

-- Using common table expressions (CTE)
WITH RankedForests AS 
(
    SELECT R.country_name, region, ROUND(SUM(forest_area_sqkm), 2) AS TOTAL_FOREST_AREA, DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(forest_area_sqkm) DESC) AS HIGHEST_FOREST_RANK
    FROM regions R JOIN forest_area F ON R.country_name = F.country_name GROUP BY R.country_name, region
)
SELECT *
FROM RankedForests
WHERE HIGHEST_FOREST_RANK = 1;


/* More analytical questions to uncover more insights.*/

SELECT * FROM forest_area;
SELECT * FROM land_area;
SELECT * FROM regions;


-- Question 6 Show the bottom 3 regions for each year along with the corresponding country code, having the smallest land area in sq miles and compare it to the top 3 having the largest land area.
SELECT * FROM 
(SELECT TOP 3 R.country_name, region, year, ROUND(SUM(total_area_sq_mi), 2) AS TOTAL_LAND_AREA, DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(total_area_sq_mi) ASC) AS BOTTOM_LAND_RANK
    FROM regions R JOIN land_area L ON R.country_code = L.country_code GROUP BY R.country_name, region, year ORDER BY BOTTOM_LAND_RANK) AS BottomRanked
	WHERE BOTTOM_LAND_RANK BETWEEN 1 AND 3;


SELECT * FROM 
(SELECT TOP 3 R.country_name, region, year, ROUND(SUM(total_area_sq_mi), 2) AS TOTAL_LAND_AREA, DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(total_area_sq_mi) DESC) AS TOP_LAND_RANK
    FROM regions R JOIN land_area L ON R.country_code = L.country_code GROUP BY R.country_name, region, year ORDER BY TOP_LAND_RANK) AS TopRanked
	WHERE TOP_LAND_RANK BETWEEN 1 AND 3;

SELECT *
FROM (
    SELECT 
        R.country_name, 
        region, 
        year, 
        ROUND(SUM(total_area_sq_mi), 2) AS TOTAL_LAND_AREA, 
        RANK() OVER(PARTITION BY year, region ORDER BY SUM(total_area_sq_mi) DESC) AS TOP_LAND_RANK
    FROM regions R 
    JOIN land_area L ON R.country_code = L.country_code 
    GROUP BY R.country_name, region, year
) AS TopRanked
WHERE TOP_LAND_RANK BETWEEN 1 AND 3
ORDER BY year, TOP_LAND_RANK;



