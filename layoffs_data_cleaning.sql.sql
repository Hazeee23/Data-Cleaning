-- ============================================================
-- LAYOFFS DATA CLEANING PROJECT
-- Tool: MySQL / MySQL Workbench
-- Database: world_layoffs
-- ============================================================

USE world_layoffs;

-- ============================================================
-- 1. EXPLORE ORIGINAL DATA
-- ============================================================

SELECT *
FROM layoffs;

SELECT COUNT(*) AS original_rows
FROM layoffs;

-- ============================================================
-- 2. CREATE STAGING TABLE
-- ============================================================
-- Create a copy of the original table so the original dataset
-- remains unchanged during the cleaning process.

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- ============================================================
-- 3. IDENTIFY DUPLICATE RECORDS
-- ============================================================
-- ROW_NUMBER() assigns a number to records that have the same
-- values across the selected columns.
--------------------------------------

-- Records with row_num > 1 are duplicate records.

SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER (
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
FROM layoffs_staging
) duplicates
WHERE row_num > 1;

-- ============================================================
-- 4. CREATE A SECOND STAGING TABLE WITH ROW NUMBERS
-- ============================================================
-- The row_num column is used to identify which duplicate
-- records should be removed.

CREATE TABLE layoffs_staging2 AS
SELECT *,
ROW_NUMBER() OVER (
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
FROM layoffs_staging;

-- ============================================================
-- 5. REMOVE DUPLICATE RECORDS
-- ============================================================

DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Verify that no duplicate groups remain.

SELECT company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions,
COUNT(*) AS duplicate_count
FROM layoffs_staging2
GROUP BY company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions
HAVING COUNT(*) > 1;

-- ============================================================
-- 6. STANDARDIZE COMPANY NAMES
-- ============================================================
-- Remove unnecessary leading and trailing spaces.

UPDATE layoffs_staging2
SET company = TRIM(company);

-- ============================================================
-- 7. STANDARDIZE INDUSTRY VALUES
-- ============================================================
-- Check values related to Crypto.

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardize Crypto-related values.

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- ============================================================
-- 8. STANDARDIZE COUNTRY VALUES
-- ============================================================
-- Review unique country values.

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Remove unnecessary trailing periods.

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- ============================================================
-- 9. STANDARDIZE DATE FORMAT
-- ============================================================
-- Convert the date from text format (MM/DD/YYYY)
-- into a proper DATE data type.

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Verify date range.

SELECT MIN(`date`) AS earliest_date,
MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- ============================================================
-- 10. HANDLE MISSING INDUSTRY VALUES
-- ============================================================
-- Convert blank industry values into NULL.

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Check records with missing industry values.

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Use other records from the same company to identify
-- a possible industry value.

SELECT t1.company,
t1.industry AS missing_industry,
t2.industry AS available_industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Fill missing industry values when the same company has
-- another record with a known industry.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Verify remaining missing industry values.

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- ============================================================
-- 11. REMOVE RECORDS WITH NO LAYOFF INFORMATION
-- ============================================================
-- These records have neither the number of employees laid off
-- nor the percentage of employees laid off.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- ============================================================
-- 12. REMOVE HELPER COLUMN
-- ============================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ============================================================
-- 13. FINAL DATA VALIDATION
-- ============================================================

-- View cleaned dataset.

SELECT *
FROM layoffs_staging2;

-- Count cleaned records.

SELECT COUNT(*) AS cleaned_rows
FROM layoffs_staging2;

-- Check remaining duplicate groups.

SELECT company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions,
COUNT(*) AS duplicate_count
FROM layoffs_staging2
GROUP BY company,
location,
industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions
HAVING COUNT(*) > 1;

-- Check remaining missing industry values.

SELECT COUNT(*) AS missing_industry
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Final table structure.

DESCRIBE layoffs_staging2;

-- ============================================================
-- END OF DATA CLEANING PROJECT
-- ============================================================
