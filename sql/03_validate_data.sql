-- 1. STAGING DATA VALIDATION

-- i. Show excluded summary row
SELECT *
FROM raw_imports
WHERE year IS NULL;

-- ii. Compare staging and fact table row counts
SELECT COUNT(*)
FROM raw_imports
WHERE year IS NOT NULL;

SELECT COUNT(*)
FROM imports;

-- iii. Check for duplicate staging rows
SELECT
	COUNT(*) AS duplicate_count,
	hts_number,
	country,
	district,
	year,
	month
FROM raw_imports
WHERE year IS NOT NULL
GROUP BY 
	hts_number, 
	country, 
	district, 
	year, 
	month
HAVING duplicate_count > 1;

-- iv. Check for missing values in legitimate rows
SELECT
	country,
	year,
	month,
	hts_number,
	description,
	district,
	customs_value
FROM raw_imports
WHERE (
	country IS NULL
	OR month IS NULL
	OR hts_number IS NULL
	OR description IS NULL
	OR district IS NULL 
	OR customs_value IS NULL
	) 
	AND year IS NOT NULL;





-- 2. DIMENSION TABLE VALIDATION

-- i. Products table validation
SELECT COUNT(*)
FROM products;

SELECT COUNT(DISTINCT hts_number)
FROM raw_imports
WHERE year IS NOT NULL;

-- ii. Countries table validation
SELECT COUNT(*)
FROM countries;

SELECT COUNT(DISTINCT country)
FROM raw_imports
WHERE year IS NOT NULL;

-- iii. Districts table validation
SELECT COUNT(*)
FROM districts;

SELECT COUNT(DISTINCT district)
FROM raw_imports
WHERE year IS NOT NULL;

-- iv. HTS description consistency check
SELECT 
	hts_number,
	COUNT(DISTINCT description) AS distinct_desc
FROM raw_imports
WHERE year IS NOT NULL
GROUP BY hts_number
HAVING distinct_desc > 1;





-- 3. DIMENSION MAPPING VALIDATION

-- i. Unmatched countries check
SELECT DISTINCT r.country
FROM raw_imports r
LEFT JOIN countries c
	ON r.country = c.country 
WHERE c.country IS NULL
	AND r.year IS NOT NULL;

-- ii. Unmatched products check
SELECT DISTINCT r.hts_number
FROM raw_imports r
LEFT JOIN products p
	ON p.hts_number = r.hts_number
WHERE p.hts_number IS NULL
	AND r.year IS NOT NULL;

-- iii. Unmatched districts check
SELECT DISTINCT r.district
FROM raw_imports r
LEFT JOIN districts d
	ON d.district = r.district
WHERE d.district IS NULL
	AND r.year IS NOT NULL;

-- iv. Product description check
SELECT 
	p.hts_number,
	p.description AS product_description,
	r.description AS raw_imports_description	
FROM products p
JOIN raw_imports r
	ON p.hts_number = r.hts_number
WHERE p.description <> r.description
	AND r.year is NOT NULL;





-- 4. FACT TABLE VALIDATION

PRAGMA foreign_key_check;

-- i. Check fact table uniqueness
SELECT
	COUNT(*) AS duplicate_count,
	product_id,
	country_id,
	district_id,
	year,
	month
FROM imports
GROUP BY 
	product_id,
	country_id,
	district_id,
	year,
	month
HAVING duplicate_count > 1;

-- ii. Verify all staging observations exist in the normalized fact table
WITH reconstructed_imports AS (
	SELECT 
		i.import_id,
		c.country,
		i.year,
		i.month,
		p.hts_number,
		p.description,
		d.district,
		i.customs_value
	FROM imports i
	JOIN countries c 
		ON c.country_id = i.country_id 
	JOIN products p 
		ON p.product_id = i.product_id 
	JOIN districts d
		ON d.district_id = i.district_id
)
SELECT 
	r.hts_number,
	r.country,
	r.district,
	r.year,
	r.month
FROM raw_imports r
LEFT JOIN reconstructed_imports i
	ON (
		r.hts_number = i.hts_number
		AND r.country = i.country
		AND r.district = i.district
		AND r.year = i.year
		AND r.month = i.month
		)
WHERE 
	i.import_id IS NULL
	AND r.year IS NOT NULL;

-- iii. Check annual country shares sum to 100%
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
)
SELECT c.year, SUM(c.annual_share_pct) AS total_share_pct
FROM country_shares c
GROUP BY c.year
ORDER BY c.year;





-- 5. FINANCIAL RECONCILIATION

-- i. Compare staging and fact table customs_value aggregation
SELECT SUM(customs_value)
FROM raw_imports
WHERE year IS NOT NULL;

SELECT SUM(customs_value)
FROM imports;

-- ii. Verify customs values match
WITH reconstructed_imports AS (
	SELECT 
		i.import_id,
		c.country,
		i.year,
		i.month,
		p.hts_number,
		p.description,
		d.district,
		i.customs_value
	FROM imports i
	JOIN countries c 
		ON c.country_id = i.country_id 
	JOIN products p 
		ON p.product_id = i.product_id 
	JOIN districts d
		ON d.district_id = i.district_id
)
SELECT 
	r.hts_number,
	r.country,
	r.district,
	r.year,
	r.month,
	r.customs_value AS raw_customs_val,
	i.customs_value AS normalized_customs_val
FROM raw_imports r
LEFT JOIN reconstructed_imports i
	ON (
		r.hts_number = i.hts_number
		AND r.country = i.country
		AND r.district = i.district
		AND r.year = i.year
		AND r.month = i.month
		)
WHERE 
	r.customs_value <> i.customs_value
	AND r.year IS NOT NULL;