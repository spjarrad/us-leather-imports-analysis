PRAGMA foreign_keys = ON;

CREATE TABLE products (
	product_id INTEGER PRIMARY KEY,
	hts_number TEXT NOT NULL,
	description TEXT NOT NULL,
	UNIQUE (hts_number)
);
	
CREATE TABLE countries (
	country_id INTEGER PRIMARY KEY,
	country TEXT NOT NULL,
	UNIQUE (country)
);

CREATE TABLE districts (
	district_id INTEGER PRIMARY KEY,
	district TEXT NOT NULL,
	UNIQUE (district)
);

CREATE TABLE imports (
	import_id INTEGER PRIMARY KEY,
	product_id INTEGER NOT NULL,
	country_id INTEGER NOT NULL,
	district_id INTEGER NOT NULL,
	year INTEGER NOT NULL,
	month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
	customs_value INTEGER NOT NULL CHECK (customs_value >= 0),
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (country_id) REFERENCES countries(country_id),
	FOREIGN KEY (district_id) REFERENCES districts(district_id),
	UNIQUE (product_id, country_id, district_id, year, month)
);

CREATE TABLE raw_imports (
	country TEXT,
	year INTEGER,
	month INTEGER,
	hts_number TEXT,
	description TEXT,
	district TEXT,
	customs_value INTEGER
);
	
