CREATE DATABASE IF NOT EXISTS world_layoffs;
USE world_layoffs;

-- Data cleaning for the layoffs dataset
-- Source table: layoffs
-- Working tables: layoffs_staging, layoffs_staging2

-- 1. Create a staging copy of the source data
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- 2. Identify duplicate records
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   company,
                   location,
                   industry,
                   total_laid_off,
                   percentage_laid_off,
                   `date`,
                   stage,
                   country,
                   funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- 3. Create a staging table with row numbers
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- 4. Review and remove duplicate records
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;


-- 5. Standardize company names
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY company;

UPDATE layoffs_staging2
SET company = TRIM(company);


-- 6. Review industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


-- 7. Standardize country values
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
  AND country LIKE '%.';


-- 8. Convert date values to DATE format
SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS converted_date
FROM layoffs_staging2;

-- Review invalid dates before changing the column type.
SELECT `date`
FROM layoffs_staging2
WHERE `date` IS NOT NULL
  AND STR_TO_DATE(`date`, '%m/%d/%Y') IS NULL;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE STR_TO_DATE(`date`, '%m/%d/%Y') IS NOT NULL;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 9. Review missing layoff information
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- 10. Review missing industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Airbnb%';


-- 11. Find existing industry values for companies with missing industries
SELECT t1.company,
       t1.industry AS missing_industry,
       t2.industry AS available_industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL
  AND t2.industry <> '';


-- 12. Populate missing industries where the company has one
-- consistent, non-empty industry value
UPDATE layoffs_staging2 AS t1
JOIN (
    SELECT company,
           MIN(industry) AS industry
    FROM layoffs_staging2
    WHERE industry IS NOT NULL
      AND industry <> ''
    GROUP BY company
    HAVING COUNT(DISTINCT industry) = 1
) AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
   OR t1.industry = '';


-- 13. Review remaining missing industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


-- 14. Remove records without layoff information
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- 15. Remove the temporary row number column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- 16. Review the cleaned dataset
SELECT *
FROM layoffs_staging2;