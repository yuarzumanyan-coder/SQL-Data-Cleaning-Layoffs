-- =============================================
-- SQL DATA CLEANING PROJECT
-- Dataset: Layoffs 2022
-- =============================================

-- View Raw Data

SELECT *
FROM world_layoffs.layoffs;



-- =============================================
-- CREATE STAGING TABLE
-- =============================================

-- Create staging table so we do not modify raw data

CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;


INSERT INTO world_layoffs.layoffs_staging
SELECT *
FROM world_layoffs.layoffs;



-- =============================================
-- CHECK DATA
-- =============================================

SELECT *
FROM world_layoffs.layoffs_staging;



-- =============================================
-- 1. REMOVE DUPLICATES
-- =============================================

-- Check potential duplicates

SELECT company,
industry,
total_laid_off,
`date`,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, `date`
) AS row_num
FROM world_layoffs.layoffs_staging;



-- See duplicate rows

SELECT *
FROM
(
SELECT company,
industry,
total_laid_off,
`date`,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, `date`
) AS row_num
FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;



-- Check example company

SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda';



-- Find real duplicates (full row)

SELECT *
FROM
(
SELECT company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions,
ROW_NUMBER() OVER(
PARTITION BY company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions
) AS row_num
FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;



-- =============================================
-- CREATE SECOND STAGING TABLE
-- =============================================

CREATE TABLE world_layoffs.layoffs_staging2
(
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



-- Insert data and generate row numbers

INSERT INTO world_layoffs.layoffs_staging2
SELECT
company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions,
ROW_NUMBER() OVER(
PARTITION BY company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions
) AS row_num
FROM world_layoffs.layoffs_staging;



-- Check table

SELECT *
FROM world_layoffs.layoffs_staging2;



-- Delete duplicate rows

DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;



-- =============================================
-- 2. STANDARDIZE DATA
-- =============================================

SELECT *
FROM world_layoffs.layoffs_staging2;



-- Check industry values

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;



-- Find blank industries

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = ''
ORDER BY industry;



-- Example company

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';



SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Airbnb%';



-- Convert blank industry to NULL

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';



-- Populate missing industries

UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



-- Check again

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL;



-- =============================================
-- STANDARDIZE INDUSTRY NAMES
-- =============================================

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;



UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency','CryptoCurrency');



-- =============================================
-- STANDARDIZE COUNTRY
-- =============================================

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;



UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);



-- Check

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;



-- =============================================
-- FIX DATE FORMAT
-- =============================================

SELECT *
FROM world_layoffs.layoffs_staging2;



UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');



ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;



-- =============================================
-- 3. CHECK NULL VALUES
-- =============================================

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;



SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- =============================================
-- 4. REMOVE USELESS ROWS
-- =============================================

DELETE
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- =============================================
-- REMOVE HELPER COLUMN
-- =============================================

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;



-- =============================================
-- FINAL CLEAN DATA
-- =============================================

SELECT *
FROM world_layoffs.layoffs_staging2;