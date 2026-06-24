/*
=============================================================
Transform ERP Customer Location Information
=============================================================

Description:
    This script performs data cleansing and transformation
    on ERP customer location data before loading it into the
    Silver layer.

Business Objectives:
    • Standardize customer identifiers.
    • Standardize country names.
    • Improve location data quality.
    • Load cleansed data into the Silver layer.

Source Table:
    bronze.erp_loc_a101

Target Table:
    silver.erp_loc_a101

=============================================================
*/


/*
=============================================================
Step 1 : Review Source Data
=============================================================

Purpose:
    Review the raw ERP customer location data before
    applying transformations.

=============================================================
*/

SELECT *
FROM bronze.erp_loc_a101;


/*
=============================================================
Step 2 : Standardize Customer Identifier
=============================================================

Purpose:
    Remove hyphens from customer identifiers to
    match the CRM customer key format.

=============================================================
*/

SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101;


/*
=============================================================
Step 3 : Validate Customer Integration
=============================================================

Purpose:
    Verify that ERP customer identifiers match the
    corresponding CRM customer records.

Expected Result:
    No unmatched customer IDs.

=============================================================
*/

SELECT
    REPLACE(cid, '-', '') AS cid
FROM bronze.erp_loc_a101

WHERE REPLACE(cid, '-', '') NOT IN
(
    SELECT DISTINCT cst_key
    FROM silver.crm_cust_info
);


/*
=============================================================
Step 4 : Analyze Country Values
=============================================================

Purpose:
    Review distinct country values before
    standardization.

=============================================================
*/

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;


/*
=============================================================
Step 5 : Standardize Country Values
=============================================================

Business Rules:
    DE  → Germany
    US
    USA → United States
    NULL or Blank → N/A
    Others → Preserve existing value

=============================================================
*/

SELECT

REPLACE(cid,'-','') AS cid,

CASE
    WHEN TRIM(cntry) = 'DE'
        THEN 'Germany'

    WHEN TRIM(cntry) IN ('US','USA')
        THEN 'United States'

    WHEN cntry IS NULL
         OR TRIM(cntry) = ''
        THEN 'N/A'

    ELSE TRIM(cntry)

END AS cntry

FROM bronze.erp_loc_a101;


/*
=============================================================
Step 6 : Load Data into Silver Layer
=============================================================

Purpose:
    Insert the transformed ERP customer location
    records into the Silver layer.

Target:
    silver.erp_loc_a101

=============================================================
*/

INSERT INTO silver.erp_loc_a101
(
    cid,
    cntry
)

SELECT

REPLACE(cid,'-',''),

CASE
    WHEN TRIM(cntry) = 'DE'
        THEN 'Germany'

    WHEN TRIM(cntry) IN ('US','USA')
        THEN 'United States'

    WHEN cntry IS NULL
         OR TRIM(cntry) = ''
        THEN 'N/A'

    ELSE TRIM(cntry)

END

FROM bronze.erp_loc_a101;


/*
=============================================================
Step 7 : Validate Loaded Data
=============================================================

Purpose:
    Verify that the transformed ERP customer location
    records have been successfully loaded into the
    Silver layer.

=============================================================
*/

SELECT *
FROM silver.erp_loc_a101;