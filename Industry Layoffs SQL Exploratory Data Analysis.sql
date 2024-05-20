-- Exploratory Data Analysis


SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)  -- Checking max laid offs
FROM layoffs_staging2;


SELECT *    -- Where whole company was laid off and ordered by funds raised in descending order
FROM layoffs_staging2
WHERE percentage_laid_off = 1
order by funds_raised_millions DESC;


SELECT company, SUM(total_laid_off)  -- Company wise total laid off in descending order.
FROM layoffs_staging2
GROUP BY company
ORDER BY  2 DESC;


SELECT MIN(`date`), MAX(`date`)  -- Date range
FROM layoffs_staging2;


SELECT industry, SUM(total_laid_off)  -- Industry wise total laid off in descending order.
FROM layoffs_staging2
GROUP BY industry
ORDER BY  2 DESC;


SELECT country, SUM(total_laid_off)  -- Country wise total laid off in descending order.
FROM layoffs_staging2
GROUP BY country
ORDER BY  2 DESC;


SELECT YEAR(`date`), SUM(total_laid_off)  -- Year wise total laid off in descending order of year.
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY  1 DESC;


SELECT stage, SUM(total_laid_off)  -- Stage wise total laid off in descending order.
FROM layoffs_staging2
GROUP BY stage
ORDER BY  2 DESC;



-- Rolling total

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off  
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL        -- Table with Year-month wise total.
GROUP BY `MONTH`
ORDER BY 1 ASC)

SELECT `MONTH`, total_off,
SUM(total_off) OVER(order by `MONTH`) AS rolling_total  -- With order by window is from to all predeceding 
FROM Rolling_Total;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)    -- First CTE with company and year wise total laid off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS   
(SELECT *,
dense_rank() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking   -- Ranking Year wise.
FROM Company_Year       -- From First CTE
WHERE years IS NOT NULL
)
 
SELECT * 
FROM Company_Year_Rank      -- Filtering on the basis of Ranking.
Where Ranking <= 5
;