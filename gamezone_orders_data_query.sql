-- DATA CLEANING

USE PortfolioProject

-- Inspect the data
SELECT TOP 10 *
FROM gamezone_orders_data;

-- Fix Date Columns (Convert to DATE)

SELECT 
    PURCHASE_TS,
    SHIP_TS,
    REFUND_TS
FROM gamezone_orders_data
WHERE 
    (TRY_CONVERT(DATE, PURCHASE_TS, 103) IS NULL AND PURCHASE_TS IS NOT NULL)
    OR
    (TRY_CONVERT(DATE, SHIP_TS, 103) IS NULL AND SHIP_TS IS NOT NULL)
    OR
    (TRY_CONVERT(DATE, REFUND_TS, 103) IS NULL AND REFUND_TS IS NOT NULL);

UPDATE gamezone_orders_data
SET PURCHASE_TS = NULL
WHERE TRY_CONVERT(DATE, PURCHASE_TS, 103) IS NULL;

UPDATE gamezone_orders_data
SET SHIP_TS = NULL
WHERE TRY_CONVERT(DATE, PURCHASE_TS, 103) IS NULL;

UPDATE gamezone_orders_data
SET REFUND_TS = NULL
WHERE TRY_CONVERT(DATE, PURCHASE_TS, 103) IS NULL;

UPDATE gamezone_orders_data
SET PURCHASE_TS = TRY_CONVERT(DATE, PURCHASE_TS, 103);

UPDATE gamezone_orders_data
SET SHIP_TS = TRY_CONVERT(DATE, SHIP_TS, 103);

UPDATE gamezone_orders_data
SET REFUND_TS = TRY_CONVERT(DATE, REFUND_TS, 103);

ALTER TABLE gamezone_orders_data
ALTER COLUMN PURCHASE_TS DATE;

ALTER TABLE gamezone_orders_data
ALTER COLUMN SHIP_TS DATE;

ALTER TABLE gamezone_orders_data
ALTER COLUMN REFUND_TS DATE;

SELECT PURCHASE_TS, SHIP_TS, REFUND_TS
FROM gamezone_orders_data;

-- Handle Missing USD_PRICE
SELECT *
FROM gamezone_orders_data
WHERE USD_PRICE IS NULL;

UPDATE gamezone_orders_data
SET USD_PRICE = 0
WHERE USD_PRICE IS NULL;

-- Fix Missing Marketing / Account Method
UPDATE gamezone_orders_data
SET MARKETING_CHANNEL = 'unknown'
WHERE MARKETING_CHANNEL IS NULL;

UPDATE gamezone_orders_data
SET ACCOUNT_CREATION_METHOD = 'unknown'
WHERE ACCOUNT_CREATION_METHOD IS NULL;

-- Fix Missing Country Code
UPDATE gamezone_orders_data
SET COUNTRY_CODE = 'unknown'
WHERE COUNTRY_CODE IS NULL;

-- Remove Duplicates
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ORDER_ID
               ORDER BY PURCHASE_TS
           ) AS row_num
    FROM gamezone_orders_data
)
DELETE FROM CTE
WHERE row_num > 1;

-- Standardize Text Columns
UPDATE gamezone_orders_data
SET 
    PRODUCT_NAME = LTRIM(RTRIM(PRODUCT_NAME)),
    PURCHASE_PLATFORM = LOWER(LTRIM(RTRIM(PURCHASE_PLATFORM))),
    MARKETING_CHANNEL = LOWER(LTRIM(RTRIM(MARKETING_CHANNEL))),
    ACCOUNT_CREATION_METHOD = LOWER(LTRIM(RTRIM(ACCOUNT_CREATION_METHOD))),
    COUNTRY_CODE = UPPER(LTRIM(RTRIM(COUNTRY_CODE)));

-- Fix Logical Errors
SELECT *
FROM gamezone_orders_data
WHERE SHIP_TS < PURCHASE_TS;

DELETE FROM gamezone_orders_data
WHERE SHIP_TS < PURCHASE_TS;

-- Check nulls
SELECT COUNT(*) FROM gamezone_orders_data WHERE USD_PRICE IS NULL;
SELECT COUNT(*) FROM gamezone_orders_data WHERE MARKETING_CHANNEL IS NULL;

-- Check data range
SELECT MIN(PURCHASE_TS), MAX(PURCHASE_TS)
FROM gamezone_orders_data;

-- Revenue check
SELECT SUM(TRY_CAST(USD_PRICE AS DECIMAL(10,2))) AS Total_Revenue
FROM gamezone_orders_data;