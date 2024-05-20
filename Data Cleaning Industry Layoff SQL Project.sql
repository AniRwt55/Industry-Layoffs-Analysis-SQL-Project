-- Data Cleaning

SELECT * 
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data (Like spelling errors etc. to keep data same across)
-- 3. Null Values or Blank Values
-- 4. Remove any Columns or rows


CREATE TABLE layoffs_staging  -- Creating Staging table to keep raw data safe in case of any mistake.
LIKE layoffs;
INSERT layoffs_staging
SELECT *
FROM layoffs;




-- 1. Remove Duplicate

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging
)                                     -- Added all the columns in partition to identify all the duplicates.
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';             -- Verifying the Duplicates



CREATE TABLE `layoffs_staging2` (     -- Creating another staging table to delete the duplicates from.
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging;

DELETE       -- Deleting Duplicates as CTE canot be updated.
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
;








-- STANDARDIZING DATA


SELECT company,TRIM(company)  -- checking for trim
FROM layoffs_staging2;

UPDATE layoffs_staging2  -- Triming the data
SET company = TRIM(company);

SELECT DISTINCT industry   -- Checking data for duplicates because of white spaces or same name etc.
FROM layoffs_staging2
ORDER BY 1;

SELECT *   -- we are considering CRYPTO = CRYPTO CURRENCY or CRYPTOCURRENCY
FROM layoffs_staging2
WHERE industry LIKE 'CRYPTO%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'CRYPTO%';

SELECT DISTINCT(country)  -- Checking in country. We found 'United States' and 'United States.' as different country.
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = TRIM(trailing '.' FROM country)  -- defining trim by '.' 
WHERE COUNTRY LIKE 'United States%';


SELECT  `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')  -- converting text to date format by giving what is the current format of data, SQL will convert it to its predefined format i.e Y/M/D. Y means Full year format and 'y' means short form of year.
FROM layoffs_staging2;



UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');  -- It has changed the date format but type is still text. we need to change the column to date



ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- now data type is changed to DATE




-- Populating Null or blank values in Industry column based other same companyi.e for same company industry must be same, so null should be populated accordingly.

UPDATE layoffs_staging2  -- CHanging blank to NULL values
SET industry = null
WHERE industry = '';


UPDATE layoffs_staging2 t1    -- Joining on the basis of Company then populating null with not null values.
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';  -- CHecking null for AirBnb etc...alter





-- Deeleting Rows and columns not required.


DELETE FROM layoffs_staging2  -- We dont need data where both are null as they are no use in our analysis
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_staging2  -- Row_num row not required.
DROP COLUMN row_num;





