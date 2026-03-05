# SQL Data Cleaning Project — Layoffs 2022

## Overview
This project focuses on cleaning a real-world dataset about company layoffs in 2022 using MySQL.
The raw data contained duplicates, inconsistent values, null entries, and incorrect data types.

## Dataset
- **Source:** Layoffs 2022
- **Fields:** company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions

## Steps Performed

### 1. Remove Duplicates
- Used `ROW_NUMBER()` with `PARTITION BY` to identify true duplicates
- Created a secondary staging table to safely delete duplicate rows

### 2. Standardize Data
- Converted blank industry values to `NULL`, then populated them using a self-join
- Unified crypto-related industry names → `Crypto`
- Removed trailing periods from country names (e.g. `United States.` → `United States`)

### 3. Fix Date Format
- Converted `date` column from `TEXT` to proper `DATE` type using `STR_TO_DATE()`

### 4. Handle NULL Values
- Identified rows where both `total_laid_off` and `percentage_laid_off` were `NULL`
- Removed those rows as they provided no analytical value

## Tools Used
- MySQL Workbench
- SQL (DDL, DML, Window Functions)

## Files
- `data_cleaning.sql` — Full cleaning script
