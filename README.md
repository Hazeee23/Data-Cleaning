# Layoffs Data Cleaning Using SQL

## Project Overview

This project focuses on cleaning a layoffs dataset using MySQL. The goal was to improve the quality and consistency of the data before using it for further analysis.

I worked with the original dataset and created staging tables so that the original data would remain unchanged during the cleaning process.

## Dataset

The dataset contains information about company layoffs, including:

* Company
* Location
* Industry
* Total laid off
* Percentage laid off
* Date
* Company stage
* Country
* Funds raised

## Tools Used

* MySQL
* MySQL Workbench
* SQL
* GitHub

## Data Cleaning Process

### 1. Created staging tables

Created copies of the original dataset before performing data cleaning.

### 2. Identified duplicate records

Used the `ROW_NUMBER()` window function together with `PARTITION BY` to identify duplicate records.

### 3. Removed duplicates

Removed records where the generated row number was greater than 1.

### 4. Standardized text data

Cleaned company names using `TRIM()` and standardized industry values, including Crypto-related entries.

Country values were also cleaned by removing unnecessary trailing periods.

### 5. Standardized dates

Converted the date column from text format into a proper MySQL `DATE` format using `STR_TO_DATE()`.

### 6. Handled missing values

Converted blank industry values to `NULL` and used records from the same company to help fill missing industry values when a valid industry value was available.

### 7. Removed records without layoff information

Removed records where both `total_laid_off` and `percentage_laid_off` were missing.

### 8. Validated the cleaned dataset

Performed final checks for duplicate records, missing industry values, row count, and table structure.

## Cleaning Results

| Metric                            | Result |
| --------------------------------- | -----: |
| Original rows                     |  2,361 |
| Cleaned rows                      |  1,995 |
| Rows removed                      |    366 |
| Duplicate groups remaining        |      0 |
| Missing industry values remaining |      1 |

The dataset was reduced from **2,361 rows to 1,995 rows** after cleaning.

## SQL Concepts Practiced

* `SELECT`
* `CREATE TABLE`
* `INSERT INTO`
* `UPDATE`
* `DELETE`
* `WHERE`
* `JOIN`
* `GROUP BY`
* `HAVING`
* `ROW_NUMBER()`
* `PARTITION BY`
* `TRIM()`
* `STR_TO_DATE()`
* `ALTER TABLE`
* `DESCRIBE`


## What I Learned

This project helped me practice using SQL for real-world data cleaning. I learned how to identify and remove duplicate records, standardize inconsistent values, convert data types, handle missing values, and validate a cleaned dataset before using it for analysis.


