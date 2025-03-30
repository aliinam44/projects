-- SQL Project - Data Cleaning

-- Selecting all data from the layoffs table to understand its structure
SELECT * FROM world_layoffs.layoffs;

-- Step 1: Creating a staging table to work in while preserving raw data as a backup
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- Data Cleaning Steps:
-- 1. Identify and remove duplicates
-- 2. Standardize and correct errors in data
-- 3. Handle null values where necessary
-- 4. Remove unnecessary columns and rows

-- 1. Removing Duplicates

-- Identifying duplicates using ROW_NUMBER()
SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
       ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Checking for true duplicates by including all key columns
SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- Deleting duplicate rows using a JOIN 
DELETE t1
FROM world_layoffs.layoffs_staging t1
JOIN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) t2
ON t1.company = t2.company AND t1.location = t2.location
AND t1.industry = t2.industry AND t1.total_laid_off = t2.total_laid_off
AND t1.percentage_laid_off = t2.percentage_laid_off AND t1.date = t2.date
AND t1.stage = t2.stage AND t1.country = t2.country AND t1.funds_raised_millions = t2.funds_raised_millions
WHERE t2.row_num > 1;

-- 2. Standardizing Data

-- Identifying NULL or empty values in the "industry" column
SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL OR industry = ''
ORDER BY industry;

-- Setting blank industry values to NULL for easier handling
UPDATE world_layoffs.layoffs_staging
SET industry = NULL
WHERE industry = '';

-- Updating missing industry values using existing data
UPDATE world_layoffs.layoffs_staging t1
JOIN world_layoffs.layoffs_staging t2
ON t1.company = t2.company
SET t1.industry = COALESCE(t1.industry, t2.industry)
WHERE t1.industry IS NULL;

-- Standardizing industry names (e.g., "Crypto Currency" → "Crypto")
UPDATE world_layoffs.layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Standardizing country names by removing trailing periods
UPDATE world_layoffs.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- Standardizing the date column
UPDATE world_layoffs.layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

-- Converting the "date" column to a proper DATE type
ALTER TABLE world_layoffs.layoffs_staging
MODIFY COLUMN `date` DATE;

-- 3. Handling Null Values

-- Leaving null values in key numeric columns for better calculations in EDA
-- No changes required

-- 4. Removing Unnecessary Data

-- Identifying rows with NULL values in critical fields
SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Deleting rows where both total_laid_off and percentage_laid_off are NULL
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Final check
SELECT * FROM world_layoffs.layoffs_staging;
