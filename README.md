# projects

This project focuses on cleaning and analyzing a dataset containing global company layoffs. The dataset includes key details such as company names, industries, locations, layoff counts, funding amounts, and dates of layoffs. Using SQL, we perform a structured data cleaning process followed by Exploratory Data Analysis (EDA) to identify trends, patterns, and insights related to layoffs over time.

Key Objectives
Data Cleaning

Create a staging table to preserve raw data.

Remove duplicate records while ensuring data integrity.

Standardize industry names and correct inconsistencies.

Handle null values appropriately.

Convert date formats to proper SQL date types.

Remove unnecessary columns and rows to streamline the dataset.

Exploratory Data Analysis (EDA)

Identify companies with the largest layoffs (both single events and cumulative).

Analyze layoffs by location, country, and industry.

Detect companies that shut down completely (100% layoffs).

Explore layoffs trends over time, including rolling totals per month.

Rank companies by layoff impact per year using window functions.
