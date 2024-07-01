-- WORLD LAYOFFS DATASET
-- DATA CLEANING

USE world_layoffs;

SELECT * FROM world_layoffs.layoffs;

CREATE TABLE world_layoffs.layoffs_staging AS SELECT * FROM world_layoffs.layoffs;
-- OR
CREATE TABLE world_layoffs.layoffs_staging LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

SELECT * FROM world_layoffs.layoffs_staging;

----------------------------------------------

-- REMOVE DUPLICATES

SELECT * FROM
(
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as ID
FROM layoffs_staging
) a
WHERE a.ID > 1;

SELECT * FROM layoffs_staging
WHERE company ='Yahoo';

SELECT * FROM layoffs_staging
WHERE company ='Casper';

-- USING CTE TO CHECK & DELETE DUPS 
-- Cannot delete dups using the below query

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as ID
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE ID > 1;

-- We do this to delete records

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `id` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as ID
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE ID > 1;

DELETE FROM layoffs_staging2
WHERE ID > 1;

----------------------------------------------

-- STANDARDIZE THE DATA

SELECT * FROM layoffs_staging2;

-- TRIM

SELECT company, TRIM(company) FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Updating to keep the same name

SELECT industry FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry = 'Crypto Currency';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- TRIM and TRAILING

SELECT DISTINCT country FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country = 'United States.';

-- OR
-- New Function

SELECT distinct country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- DATE - Changing from string to date

SELECT count(`date`) FROM layoffs_staging2
WHERE `date` <> 'NULL';

SELECT count(`date`) FROM layoffs_staging2;

SELECT `date` FROM layoffs_staging2;

SELECT `date`,STR_to_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_to_DATE(`date`,'%m/%d/%Y')
WHERE `date` <> 'NULL';

-- Since I am not able to update datatype of the Date column because of 'NULL' I will update the Null value to a 
-- high end date so that I can Alter the table.

UPDATE layoffs_staging2
SET `date` = '9999-12-31'
WHERE `date` = 'NULL';

-- Modifying the table to change the `date` datatype to DATE 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

----------------------------------------------

-- NULLS AND BLANKS

SELECT * FROM layoffs_staging2
WHERE industry = 'NULL'
OR industry = '';

SELECT  ls1.company, ls1.location,ls1.industry, ls2.industry from layoffs_staging2 ls1
JOIN  layoffs_staging2 ls2
ON ls1.company = ls2.company and ls1.location = ls2.location
WHERE ls1.industry = 'NULL'
OR ls1.industry = '';

UPDATE layoffs_staging2 ls1
JOIN  layoffs_staging2 ls2
ON ls1.company = ls2.company and ls1.location = ls2.location
SET ls1.industry = ls2.industry
WHERE (ls1.industry = 'NULL' OR ls1.industry = '')
AND ls2.industry <> 'NULL';

-- the above query does not update the rows so doing the below update first and then rerunning the above update again.
UPDATE layoffs_staging2
SET industry = 'NULL'
WHERE industry = '';

SELECT * from layoffs_staging2
WHERE company = 'Airbnb';

-- DELETING UNWANTED ROWS

SELECT * FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';

DELETE FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';

ALTER TABLE layoffs_staging2
DROP COLUMN id


