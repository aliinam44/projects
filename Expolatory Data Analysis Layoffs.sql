-- Exploratory Data Analysis (EDA)

-- In this section, we explore the dataset to identify trends, patterns, outliers, and other insights.
-- Typically, EDA begins with a hypothesis or a specific question, but here, we'll take an open-ended approach to see what stands out.

SELECT * 
FROM world_layoffs.layoffs_staging;

-- Basic Aggregations

-- Finding the maximum number of layoffs in a single entry
SELECT MAX(total_laid_off) AS max_layoffs
FROM world_layoffs.layoffs_staging;

-- Checking the range of percentage layoffs to understand how severe some layoffs were
SELECT MAX(percentage_laid_off) AS max_percentage, MIN(percentage_laid_off) AS min_percentage
FROM world_layoffs.layoffs_staging
WHERE percentage_laid_off IS NOT NULL;

-- Identifying companies that had a 100% layoff (i.e., the company shut down)
SELECT *
FROM world_layoffs.layoffs_staging
WHERE percentage_laid_off = 1;
-- These appear to be mostly startups that went out of business during this period.

-- Checking high-profile companies that went under by looking at those with 100% layoffs sorted by funding
SELECT *
FROM world_layoffs.layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt and Quibi are notable cases, with Quibi raising nearly $2 billion before shutting down.


-- Grouped Aggregations ------------------------------------------------------------------------------

-- Companies with the biggest single-day layoffs
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the highest total layoffs across all recorded events
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Locations with the highest total layoffs
SELECT location, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 10;

-- Total layoffs per country
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging
GROUP BY country
ORDER BY total_layoffs DESC;

-- Total layoffs per year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging
GROUP BY year
ORDER BY year ASC;

-- Industry-wise layoffs
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Layoffs by company funding stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging
GROUP BY stage
ORDER BY total_layoffs DESC;


-- Advanced Queries ------------------------------------------------------------------------------

-- Identifying the top 3 companies with the most layoffs each year
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
  FROM world_layoffs.layoffs_staging
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, year, total_layoffs, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS ranking
  FROM Company_Year
)
SELECT company, year, total_layoffs, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND year IS NOT NULL
ORDER BY year ASC, total_layoffs DESC;

-- Rolling total of layoffs per month
WITH DATE_CTE AS 
(
  SELECT DATE_FORMAT(date, '%Y-%m') AS month, SUM(total_laid_off) AS total_layoffs
  FROM world_layoffs.layoffs_staging
  GROUP BY month
  ORDER BY month ASC
)
SELECT month, SUM(total_layoffs) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY month ASC;
