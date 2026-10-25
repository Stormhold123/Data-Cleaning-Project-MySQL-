SELECT * 
FROM layoffs;

-- Creating work table and separating raw

CREATE TABLE layoffs_working
LIKE layoffs;

SELECT * 
FROM layoffs_working;

INSERT layoffs_working
SELECT *
FROM layoffs;

-- Locating Duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Confirming duplicates

SELECT *
FROM layoffs_working
WHERE company = 'Casper';

-- creating 2nd work table to delete duplicates

CREATE TABLE `layoffs_working2` (
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

SELECT *
FROM layoffs_working2;

INSERT INTO layoffs_working2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;


-- Removing Duplicates

SELECT *
FROM layoffs_working2
WHERE row_num > 1;

DELETE
FROM layoffs_working2
WHERE row_num > 1;

SELECT *
FROM layoffs_working2;

-- Standardizing the data

-- Noticed some white space in company so it needs to be trimmed

UPDATE layoffs_working2
SET company = TRIM(company);

-- checking industry

SELECT DISTINCT industry
FROM layoffs_working2
ORDER BY 1;

-- Updating needed areas

SELECT *
FROM layoffs_working2 
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_working2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- checking location

SELECT DISTINCT location
FROM layoffs_working2
ORDER BY 1;

-- checking country

SELECT DISTINCT country
FROM layoffs_working2
ORDER BY 1;

-- Fixing issue found

UPDATE layoffs_working2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_working2
ORDER BY 1;

-- Fixing date format

SELECT `date`
FROM layoffs_working2;

UPDATE layoffs_working2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_working2
MODIFY COLUMN `date` DATE;

-- Handling Nulls and Blanks where necessary

SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_working2
SET industry = NULL 
WHERE industry = '';

SELECT DISTINCT industry
FROM layoffs_working2
WHERE industry IS NULL
OR industry = '';

SELECT * 
FROM layoffs_working2
WHERE company = 'Airbnb';

SELECT * 
FROM layoffs_working2 t1
JOIN layoffs_working2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_working2 t1
JOIN layoffs_working2 t2
    ON t1.company = t2.company
    SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_working2;

-- Deleting row_num since i no longer need it


ALTER TABLE layoffs_working2
DROP COLUMN row_num;

SELECT *
FROM layoffs_working2;