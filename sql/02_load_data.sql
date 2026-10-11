-- Dimension table: Countries
INSERT INTO countries (country)
SELECT DISTINCT country
FROM raw_imports
WHERE year is NOT NULL;

-- Dimension table: Products
INSERT INTO products (hts_number, description)
SELECT DISTINCT hts_number, description
FROM raw_imports
WHERE year is NOT NULL;

--Dimension table: Districts
INSERT INTO districts (district)
SELECT DISTINCT district
FROM raw_imports
WHERE year IS NOT NULL;

-- Fact table: Imports
INSERT INTO imports (
	product_id,
	country_id,
	district_id,
	year,
	month,
	customs_value
	)
SELECT
	p.product_id,
	c.country_id,
	d.district_id,
	r.year,
	r.month,
	r.customs_value
FROM raw_imports r
LEFT JOIN countries c
	ON c.country = r.country
LEFT JOIN products p
	ON p.hts_number = r.hts_number
LEFT JOIN districts d
	ON d.district = r.district
WHERE r.year IS NOT NULL;
