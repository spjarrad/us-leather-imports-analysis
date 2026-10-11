-- ====================================================
--           US Leather Imports Analysis
-- Monthly USITC imports for consumption, 2021 - 2025
--              Customs values in USD
-- ====================================================





-- RESEARCH QUESTION 1: TOP SUPPLIER COUNTRIES

-- i. Top 10 supplier countries by total customs value
SELECT
    c.country,
    SUM(i.customs_value) AS total_customs_val
FROM imports i
JOIN countries c
    ON c.country_id = i.country_id
GROUP BY c.country
ORDER BY total_customs_val DESC
LIMIT 10;





-- RESEARCH QUESTION 2: SUPPLIER CONCENTRATION

-- i. Italy and France's combined five-year import-value share
WITH numerator as (
	SELECT SUM(i.customs_value) AS it_fr_customs_val
	FROM imports i
	JOIN countries c
		ON c.country_id = i.country_id
	WHERE c.country IN ('Italy', 'France')
),
denominator AS (
	SELECT SUM(customs_value) AS total_customs_value
	FROM imports
)
SELECT ((n.it_fr_customs_val * 100.0) / d.total_customs_value) AS import_val_share_pct
FROM numerator n
CROSS JOIN denominator d;


-- ii. Italy and France's annual import-value share
WITH numerator as (
	SELECT i.year, SUM(i.customs_value) AS it_fr_customs_val
	FROM imports i
	JOIN countries c
		ON c.country_id = i.country_id
	WHERE c.country IN ('Italy', 'France')
	GROUP BY i.year
),
denominator AS (
	SELECT i.year, SUM(i.customs_value) AS total_customs_value
	FROM imports i
	GROUP BY i.year
)
SELECT 
	n.year,
	n.it_fr_customs_val,
	d.total_customs_value,
	((n.it_fr_customs_val * 100.0) / d.total_customs_value) AS import_val_share_pct
FROM numerator n 
JOIN denominator d
	ON n.year = d.year
ORDER BY n.year;


-- iii. Compare Italy & France's customs values in 2023 & 2025
SELECT 
	i.year, 
	c.country, 
	SUM(i.customs_value) AS total_customs_value
FROM imports i
JOIN countries c
	ON c.country_id = i.country_id
WHERE c.country IN ('Italy', 'France')
	AND i.year IN (2023, 2025)
GROUP BY i.year, c.country
ORDER BY i.year, c.country;





-- RESEARCH QUESTION 3: PRODUCT-CATEGORY PERFORMANCE

-- i. Product categories ranked by total customs value
SELECT p.hts_number, SUM(i.customs_value) AS total_customs_val
FROM imports i
JOIN products p
	ON i.product_id = p.product_id 
GROUP BY p.hts_number
ORDER BY total_customs_val DESC;

-- ii. Annual customs value by HTS product category
SELECT 
	i.year, 
	p.hts_number, 
	SUM(i.customs_value) AS total_customs_val
FROM imports i
JOIN products p
	ON i.product_id = p.product_id
GROUP BY p.hts_number, i.year
ORDER BY i.year, p.hts_number;

-- iii. Annual share of import customs value by HTS category
WITH numerator AS (
	SELECT 
		i.year, 
		p.hts_number, 
		SUM(i.customs_value) AS total_customs_val
	FROM imports i
	JOIN products p
		ON i.product_id = p.product_id 
	GROUP BY p.hts_number, i.year
),
denominator AS (
	SELECT  
		i.year,
		SUM(i.customs_value) AS annual_customs_val
	FROM imports i
	GROUP BY i.year
)
SELECT 
	n.year,
	n.hts_number,
	n.total_customs_val,
	((n.total_customs_val * 100.0) / d.annual_customs_val) AS annual_share_pct
FROM numerator n
JOIN denominator d
	ON n.year = d.year
ORDER BY n.year, n.hts_number;




-- RESEARCH QUESTION 4: COUNTRIES GAIN/LOSS SHARE

-- i. Annual country-share
WITH numerator AS (
	SELECT
		i.year,
		c.country,
		SUM(i.customs_value) AS total_customs_val
	FROM imports i
	JOIN countries c
		ON c.country_id = i.country_id 
	GROUP BY i.year, c.country
),
denominator AS (
	SELECT 
		i.year,
		SUM(i.customs_value) AS total_annual_customs_val
	FROM imports i
	GROUP BY i.year
)
SELECT 
	n.year,
	n.country,
	n.total_customs_val,
	((n.total_customs_val * 100.0) / (d.total_annual_customs_val))
		AS annual_share_pct
FROM numerator n
JOIN denominator d
	ON n.year = d.year 
ORDER BY n.year, n.country;

-- ii. Country-share comparison
WITH numerator AS (
	SELECT
		i.year,
		c.country,
		SUM(i.customs_value) AS total_customs_val
	FROM imports i
	JOIN countries c
		ON c.country_id = i.country_id 
	GROUP BY i.year, c.country
),
denominator AS (
	SELECT 
		i.year,
		SUM(i.customs_value) AS total_annual_customs_val
	FROM imports i
	GROUP BY i.year
),
country_shares AS (
	SELECT 
		n.year,
		n.country,
		n.total_customs_val,
		((n.total_customs_val * 100.0) / (d.total_annual_customs_val))
			AS annual_share_pct
	FROM numerator n
	JOIN denominator d
		ON n.year = d.year 
),
share_comparison AS (
	SELECT 
		c.country,
		SUM(
			CASE
				WHEN c.year = 2021 THEN c.annual_share_pct
				ELSE 0
			END
		) AS '2021_share_pct',		
		SUM(
			CASE
				WHEN c.year = 2025 THEN c.annual_share_pct
				ELSE 0
			END
		) AS '2025_share_pct'
	FROM country_shares c
	WHERE c.year IN (2021, 2025)
	GROUP BY c.country
)
SELECT
	s.country,
	s.'2021_share_pct',
	s.'2025_share_pct',
	(s.'2025_share_pct' - s.'2021_share_pct') AS share_change_pp
FROM share_comparison s
ORDER BY share_change_pp;




-- RESEARCH QUESTION 5: District performance

-- i. Customs districts ranked by total import customs value
SELECT d.district, SUM(i.customs_value) AS total_customs_val
FROM imports i
JOIN districts d
	ON d.district_id = i.district_id 
GROUP BY d.district 
ORDER BY total_customs_val DESC;

SELECT i.year, d.district, SUM(i.customs_value) AS total_customs_val
FROM imports i
JOIN districts d
	ON d.district_id = i.district_id 
WHERE i.year IN (2021, 2025) 
	AND d.district IN ('New York, NY', 'Los Angeles, CA')
GROUP BY i.year, d.district 
ORDER BY total_customs_val DESC;