-- WORLD LAYOFFS DATASET
-- EXPLORATORY DATA ANALYSIS

USE world_layoffs;

SELECT * FROM layoffs_staging2
WHERE company = 'Amazon';

SELECT MAX(total_laid_off), MAX(percentage_laid_off) -- Not giving right values, here the output was Null.
FROM layoffs_staging2;

SELECT total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL; -- Does not give the right values.

UPDATE  layoffs_staging2 -- so updated NULLs to blank.
SET total_laid_off =''
WHERE total_laid_off = 'NULL';

SELECT total_laid_off
FROM layoffs_staging2 where total_laid_off = 'NULL';

SELECT TRIM(total_laid_off) FROM layoffs_staging2; -- tried trimming, did not help.

-- this query will return highest as 87 in total_laid_iff cos the datatype of thate column is text.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off  DESC;

-- To get the right value,column needs to be casted wich converts text to a int using  
-- the above logic and then goves you the correct value of 2434.

SELECT MAX(CAST(total_laid_off AS UNSIGNED))
FROM layoffs_staging2;

SELECT MAX(CAST(percentage_laid_off AS UNSIGNED))
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY CAST(total_laid_off AS UNSIGNED) DESC;

-- Updated Nulls to blank to change the datatype of the column to int.

UPDATE  layoffs_staging2 -- so updated NULLs to blank.
SET total_laid_off = NULL
WHERE total_laid_off = '';

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off int;

-- Calcuating total 'total_laid_off' for every company

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- DATe Range employees were laid off

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
WHERE `date` <> '9999-12-31';

-- What industry had the max layoffs

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- Which country was the most impacted 

SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- year on year basis layoffs in various country
SELECT year(`date`),country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY 1,2
ORDER BY 3 DESC;

-- Layoffs each year

SELECT year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- Layoffs based on Stages - Stages are funding rounds.

SELECT (stage), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- Calculating the total_laid_off for month-year combination

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) 
FROM layoffs_staging2
-- WHERE SUBSTRING(`date`,1,7) <> '9999-12'
GROUP BY `MONTH`
ORDER BY 1;

-- Calculating Rolling Totals

WITH Rolling_totals AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
-- WHERE SUBSTRING(`date`,1,7) <> '9999-12'
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`,
total_layoffs,
SUM(total_layoffs)OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_totals;

-- CAlculating The total_laid_off every year for every company
SELECT company, year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1,2
ORDER BY 3 DESC;

-- Ranking the companies yearly ( which company laid off highest every year) 

WITH Rank_company AS
(
SELECT company, year(`date`) AS `year` , SUM(total_laid_off) as total_layoffs
FROM layoffs_staging2
GROUP BY 1,2
ORDER BY 3 DESC
),
All_ranking AS
(
SELECT
company, `year`, total_layoffs,
DENSE_RANK()over(PARTITION BY `year` ORDER BY total_layoffs DESC) AS ranking
FROM Rank_company
-- ORDER BY ranking ASC
)
SELECT * FROM all_ranking
WHERE ranking <=5;

