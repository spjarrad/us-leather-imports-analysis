# U.S. Leather Imports Analysis (2021 - 2025)
### SQL, SQLite & DBeaver

## Project Overview

After six years working in leathercrafting, I wanted to explore trade data relating to the type of products I've made over the years. I already expected Italy and France to be major suppliers of leather goods to the U.S. due to the fashion industry there, but was curious to see what other countries were close behind.

Using publicly available data from the U.S. International Trade Commission (USITC), I built a relational database in SQLite and analyzed import customs values by supplier country, product category, and U.S. customs district. Some of the shifts were more surprising than the overall totals suggested.

## Analysis Questions

1. Which countries supplied the most leather goods to the U.S. by customs value?
2. How concentrated were imports among major suppliers?
3. Which product categories accounted for the most import value, and how did their shares change?
4. Which major supplier countries gained or lost import-value share between 2021 and 2025?
5. Which U.S. customs districts recorded the most import value, and how did their shares change?

## Tools Used

- **SQL (SQLite):** relational database design, data loading, validation, and analysis
- **DBeaver:** database management, CSV import, and SQL development

## Data

**Source:** [USITC DataWeb](https://dataweb.usitc.gov/) - U.S. Imports for Consumption  
**Period:** January 2021 - December 2025  
**Observations:** 64,018  
**Total customs value:** $18.64 billion  
**Coverage:** 173 supplier countries and 41 U.S. customs districts

The analysis covers four Harmonized Tariff Schedule (HTS) categories:

| HTS Code | Product Category |
|---|---|
| `420211` | Leather luggage and similar articles |
| `420221` | Leather handbags |
| `420231` | Leather wallets and pocket articles |
| `420291` | Other leather bags and containers |

## Analysis Workflow

1. Prepared the USITC export and imported the data into a staging table.
2. Normalized the data into product, country, and district dimension tables and an imports fact table.
3. Checked missing values, duplicates, dimension mappings, foreign keys, and record-level accuracy. All 64,018 observations and $18.64 billion in customs value reconciled with the source data.
4. Used joins, CTEs, aggregation, and conditional aggregation to answer the five analysis questions.

## Key Findings

1. Which countries supplied the most leather goods to the U.S. by customs value?

Italy, France, and Vietnam were the three largest suppliers by total import customs value. Top 10 suppliers to the U.S. are displayed in the table below.

### Top 10 Supplier Countries (2021 - 2025)
| Rank | Supplier Country | Total Customs Value (USD) |
|---:|---|---:|
| 1 | Italy | $6,267,601,934 |
| 2 | France | $4,205,729,539 |
| 3 | Vietnam | $1,659,181,844 |
| 4 | Cambodia | $1,363,923,139 |
| 5 | India | $1,203,544,375 |
| 6 | China | $873,050,903 |
| 7 | Philippines | $714,259,282 |
| 8 | Spain | $594,025,556 |
| 9 | Indonesia | $482,761,754 |
| 10 | Mexico | $332,672,191 |

*Rankings reflect U.S. import customs value for HTS codes 420211, 420221, 420231, and 420291 from 2021 - 2025.*


2. How concentrated were imports among major suppliers?

Italy and France accounted for **56.18%** of total import customs value. The remaining eight countries in the top 10 contributed another **38.75%**, bringing the top 10's combined share to 94.93%. The other 163 supplier countries accounted for just **5.07%**.


3. Which product categories accounted for the most import value, and how did their shares change?

### Import Customs Value by Product Category (2021 - 2025)

| HTS Code | Product Category | Total Customs Value (USD) |
|---|---|---:|
| 420221 | Leather handbags | $12,169,912,612 |
| 420291 | Other leather bags and containers | $3,928,146,671 |
| 420231 | Leather wallets and pocket articles | $2,242,256,697 |
| 420211 | Leather luggage and similar articles | $301,841,725 |

Handbags led all categories, representing **65.28%** of total customs value. Despite a **3.42%** decline in value from 2021 to 2025, their share grew by **2.65 percentage points**. Wallets saw the steepest decline, falling **19.15%** over the same period.


4. Which major supplier countries gained or lost import-value share between 2021 and 2025?

Between 2021 and 2025, Italy's share fell **5.08 percentage points** while France's grew **4.85 points**. Their combined share fell just **0.23 points**, masking substantial shifts between the two countries. Vietnam and Mexico each gained over one point, while China lost **1.89 points**.


5. Which U.S. customs districts recorded the most import value, and how did their shares change?

New York and Los Angeles accounted for **69.39%** of the five-year customs value. Their combined annual share declined from **71.66%** in 2021 to **68.03%** in 2025.

### Top 5 U.S. Customs Districts (2021 - 2025)

| Rank | Customs District | Total Customs Value (USD) |
|---:|---|---:|
| 1 | New York, NY | $9,413,150,327 |
| 2 | Los Angeles, CA | $3,522,195,595 |
| 3 | Tampa, FL | $1,175,728,394 |
| 4 | Savannah, GA | $834,187,452 |
| 5 | Dallas-Fort Worth, TX | $821,166,265 |

*Rankings reflect U.S. import customs value for the four selected HTS categories from 2021 - 2025.*


## Repository Contents

- `sql/01_create_tables.sql` - database schema, keys, and constraints
- `sql/02_load_data.sql` - dimension and fact-table loading
- `sql/03_validate_data.sql` - data-integrity checks and financial reconciliation
- `sql/04_analysis.sql` - queries answering the five analysis questions
- `README.md` - project overview, methodology, and findings
- `data/DataWeb-Query-Export.csv` - prepared dataset used for the analysis
- `data/leather_imports.db` - completed SQLite database containing the staging, dimension, and fact tables, ready to explore and query

## Reproducing the Analysis

**NOTE: I've included the prepared csv dataset used in this analysis for convenience.**

1. Use the prepared dataset in data/DataWeb-Query-Export.csv, or download the original monthly U.S. Imports for Consumption data from USITC DataWeb using the four HTS codes listed above.
2. Create a fresh SQLite database and run `sql/01_create_tables.sql`.
3. Import the CSV data into `raw_imports` using DBeaver. The grand-total summary row remains in staging and is excluded from the normalized tables.
4. Run `sql/02_load_data.sql`, followed by `sql/03_validate_data.sql` and `sql/04_analysis.sql`.

## Limitations

This project covers four selected HTS categories, not the entire U.S. leather-goods market. Customs value is not the same as retail sales or units sold, and customs districts don't necessarily represent the goods' final destinations.

## Future Work

My next project will examine U.S. leather-goods exports. I eventually plan to combine the cleaned import and export datasets to look at U.S. leather-goods trade from both directions.
