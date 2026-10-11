# Layoffs Data Cleaning Using MySQL

## Project Overview
This project focuses on cleaning and standardizing a layoffs dataset using MySQL. It demonstrates data-cleaning techniques such as identifying duplicates, standardizing values, converting date formats, handling missing values, and removing incomplete records.

## Tools Used
- MySQL
- MySQL Workbench
- SQL

## Dataset
- **File:** `layoffs.csv`
- **Database:** `world_layoffs`
- **Source table:** `layoffs`
- **Working tables:** `layoffs_staging`, `layoffs_staging2`

## Project Workflow
1. Create the `world_layoffs` database.
2. Import `layoffs.csv` into MySQL Workbench.
3. Create staging tables to preserve the original data.
4. Identify and remove duplicate records.
5. Standardize company and country values.
6. Convert dates into the appropriate format.
7. Review and handle missing values.
8. Remove records without layoff information.
9. Review the cleaned dataset.

## How to Import the Dataset

1. Open MySQL Workbench and connect to your MySQL server.
2. Run the following SQL:

   ```sql
   CREATE DATABASE IF NOT EXISTS world_layoffs;
   USE world_layoffs;
   ```

3. In the **SCHEMAS** panel, refresh the schemas, right-click `world_layoffs`, and select **Table Data Import Wizard**.
4. Select `layoffs.csv`, choose `world_layoffs` as the target schema, set the table name to `layoffs`, review the column mappings and data types, and complete the import.

Verify the import:

```sql
SHOW TABLES;
SELECT * FROM layoffs LIMIT 10;
```

## SQL Script
The cleaning queries are available in [`sql/layoffs_data_cleaning.sql`](sql/layoffs_data_cleaning.sql).

## Key Skills Demonstrated
- SQL data cleaning
- Common Table Expressions (CTEs)
- Window functions (`ROW_NUMBER`)
- Joins and subqueries
- Data standardization
- NULL handling
- Date conversion
- Data validation

## Project Structure

```text
layoffs-data-cleaning-sql/
├── README.md
├── layoffs.csv
└── sql/
    └── layoffs_data_cleaning.sql
```

## Note
The original source table is retained separately from the staging tables used for cleaning.
