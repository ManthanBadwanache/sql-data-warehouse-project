/*
=============================================================
Transform CRM Product Information
=============================================================

Description:
    This script performs data validation, cleansing and
    transformation on CRM product data before loading it
    into the Silver layer.

Business Objectives:
    • Validate primary keys.
    • Extract category information.
    • Improve data quality.
    • Standardize product attributes.
    • Generate product end dates.
    • Load cleansed data into the Silver layer.

Source Table:
    bronze.crm_prd_info

Target Table:
    silver.crm_prd_info

=============================================================
*/


/*
=============================================================
Step 1 : Review Source Data
=============================================================
Purpose:
    Review the raw CRM product data before applying any
    transformations.

=============================================================
*/

SELECT 
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM 
	bronze.crm_prd_info;


/*
=============================================================
Step 2 : Validate Primary Key
=============================================================
Purpose:
    Check for duplicate or NULL product IDs.

Expected Result:
    No duplicate or NULL product IDs.

=============================================================
*/

SELECT  COUNT(*),
	 	prd_id
FROM 	bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 2 OR prd_id is null;


/*
=============================================================
Step 3 : Validate Category Mapping
=============================================================
Purpose:
    Verify that the category identifier embedded within
    the product key matches the ERP category master data.

=============================================================
*/

SELECT DISTINCT  id
FROM bronze.erp_px_cat_g1v2;

SELECT REPLACE (SUBSTRING(prd_key,1,5),'-','_') 
FROM bronze.crm_prd_info;


/*
=============================================================
Step 4 : Verify Category Integration
=============================================================
Purpose:
    Confirm that every CRM product category exists in the
    ERP category master.

Expected Result:
    No records returned.

=============================================================
*/

SELECT 
	prd_id,
	prd_key,
	REPLACE (SUBSTRING(prd_key,1,5),'-','_') as  cat_id,
	SUBSTRING(prd_key,7, LENGTH(prd_key)) as prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM 
	bronze.crm_prd_info

WHERE 	 REPLACE (SUBSTRING(prd_key,1,5),'-','_')
NOT IN 	(SELECT DISTINCT  id FROM bronze.erp_px_cat_g1v2);


/*
=============================================================
Step 5 : Validate Product Keys
=============================================================
Purpose:
    Verify that transformed product keys match the sales
    table for future integration.

=============================================================
*/

SELECT sls_prd_key
FROM bronze.crm_sales_details;


/*
=============================================================
Step 6 : Validate Product Name
=============================================================
Purpose:
    Check for unwanted leading and trailing spaces.

Expected Result:
    No records returned.

=============================================================
*/

SELECT COUNT(*)
FROM bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm;


/*
=============================================================
Step 7 : Validate Product Cost
=============================================================
Purpose:
    Identify NULL or negative product costs before
    transformation.

=============================================================
*/

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost is null
OR prd_cost < 0;


/*
=============================================================
Step 8 : Replace NULL Product Cost
=============================================================
Business Rule:
    Replace NULL product cost with 0.

=============================================================
*/

SELECT 
	prd_id,
	prd_key,
	REPLACE (SUBSTRING(prd_key,1,5),'-','_') as  cat_id,
	SUBSTRING(prd_key,7, LENGTH(prd_key)) as prd_key,
	prd_nm,
	COALESCE(prd_cost,0) AS prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM 
	bronze.crm_prd_info;

/*
=============================================================
Step 9 : Standardize Product Line
=============================================================
Purpose:
    Standardize abbreviated product line values into
    meaningful business descriptions.

Business Rules:
    R → Road
    M → Mountain
    S → Other Sales
    T → Touring
    Others → N/A

=============================================================
*/

SELECT 
	CASE UPPER(TRIM(prd_line))
		WHEN 'R' THEN 'Road'
		WHEN 'M' THEN 'Mountain'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'N/A'
	END AS prd_line 
FROM bronze.crm_prd_info;


/*
=============================================================
Step 10 : Validate Product Date Range
=============================================================
Purpose:
    Identify product records where the end date
    occurs before the start date.

Expected Result:
    Review records before applying transformation.

=============================================================
*/

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/*
=============================================================
Step 11 : Generate Product End Date
=============================================================
Purpose:
    Generate product end dates using the start date of
    the next product version.

Business Rule:
    Product End Date =
        Next Product Start Date - 1 Day

=============================================================
*/

SELECT
    *,
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - INTERVAL '1 day' AS prd_end_dt_test
FROM bronze.crm_prd_info;


/*
=============================================================
Step 12 : Build Final Transformation
=============================================================
Purpose:
    Combine all cleansing and transformation rules into
    a single production-ready query.

Transformation Rules:
    • Extract Category ID.
    • Generate Product Number.
    • Replace NULL Product Cost.
    • Generate Product End Date.

=============================================================
*/

SELECT 
	prd_id,
	REPLACE (SUBSTRING(prd_key,1,5),'-','_') as  cat_id,
	prd_key,
	SUBSTRING(prd_key,7, LENGTH(prd_key)) as prd_key,
	prd_nm,
	COALESCE(prd_cost,0) AS prd_cost,
	prd_line,
	CAST(prd_start_dt AS DATE),
	CAST(LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - INTERVAL '1 day' AS DATE ) AS prd_end_dt
FROM 
	bronze.crm_prd_info;


/*
=============================================================
Step 13 : Load Data into Silver Layer
=============================================================
Purpose:
    Insert the transformed product records into the
    Silver layer.

Target:
    silver.crm_prd_info

=============================================================
*/

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    prd_line,
    CAST(prd_start_dt AS DATE),
    CAST(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - INTERVAL '1 day'
    AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;


/*
=============================================================
Step 14 : Validate Loaded Data
=============================================================
Purpose:
    Verify that the transformed product records have
    been successfully loaded into the Silver layer.

=============================================================
*/

SELECT *
FROM silver.crm_prd_info;