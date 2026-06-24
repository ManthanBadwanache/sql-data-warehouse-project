/*
=============================================================
Transform ERP Customer Information
=============================================================

Description:
    This script performs data cleansing and transformation
    on ERP customer master data before loading it into the
    Silver layer.

Business Objectives:
    • Standardize customer identifiers.
    • Validate customer birth dates.
    • Standardize gender values.
    • Improve customer master data quality.
    • Load cleansed data into the Silver layer.

Source Table:
    bronze.erp_cust_az12

Target Table:
    silver.erp_cust_az12

=============================================================
*/


/*
=============================================================
Step 1 : Review Source Data
=============================================================

Purpose:
    Review the raw ERP customer data before applying
    transformations.

=============================================================
*/

SELECT *
FROM bronze.erp_cust_az12;


/*
=============================================================
Step 2 : Standardize Customer Identifier
=============================================================

Purpose:
    Remove the 'NAS' prefix from customer identifiers
    to match the CRM customer key format.

=============================================================
*/

SELECT
    CASE
        WHEN cid LIKE 'NAS%'
        THEN SUBSTRING(cid,4)
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;


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
    CASE
        WHEN cid LIKE 'NAS%'
        THEN SUBSTRING(cid,4)
        ELSE cid
    END AS cid
FROM bronze.erp_cust_az12

WHERE
CASE
    WHEN cid LIKE 'NAS%'
    THEN SUBSTRING(cid,4)
    ELSE cid
END

NOT IN
(
    SELECT DISTINCT cst_key
    FROM silver.crm_cust_info
);


/*
=============================================================
Step 4 : Validate Birth Date
=============================================================

Purpose:
    Identify invalid birth dates.

Business Rule:
    Future birth dates are considered invalid
    and will be replaced with NULL.

=============================================================
*/

SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate > CURRENT_DATE;


/*
=============================================================
Step 5 : Standardize Gender Values
=============================================================

Business Rules:

Male:
    M
    Male

Female:
    F
    Female

Others:
    Unknown

=============================================================
*/

SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

SELECT
CASE
    WHEN UPPER(TRIM(gen)) IN ('M','MALE')
        THEN 'Male'

    WHEN UPPER(TRIM(gen)) IN ('F','FEMALE')
        THEN 'Female'

    ELSE 'Unknown'

END AS gen

FROM bronze.erp_cust_az12;


/*
=============================================================
Step 6 : Build Final Transformation
=============================================================

Purpose:
    Apply all transformation rules to produce a
    production-ready dataset.

=============================================================
*/

SELECT

CASE
    WHEN cid LIKE 'NAS%'
    THEN SUBSTRING(cid,4)
    ELSE cid
END AS cid,

CASE
    WHEN bdate > CURRENT_DATE
    THEN NULL
    ELSE bdate
END AS bdate,

CASE
    WHEN UPPER(TRIM(gen)) IN ('M','MALE')
        THEN 'Male'

    WHEN UPPER(TRIM(gen)) IN ('F','FEMALE')
        THEN 'Female'

    ELSE 'Unknown'

END AS gen

FROM bronze.erp_cust_az12;


/*
=============================================================
Step 7 : Load Data into Silver Layer
=============================================================

Purpose:
    Insert the transformed ERP customer records into
    the Silver layer.

Target:
    silver.erp_cust_az12

=============================================================
*/

INSERT INTO silver.erp_cust_az12
(
    cid,
    bdate,
    gen
)

SELECT

CASE
    WHEN cid LIKE 'NAS%'
    THEN SUBSTRING(cid,4)
    ELSE cid
END,

CASE
    WHEN bdate > CURRENT_DATE
    THEN NULL
    ELSE bdate
END,

CASE
    WHEN UPPER(TRIM(gen)) IN ('M','MALE')
        THEN 'Male'

    WHEN UPPER(TRIM(gen)) IN ('F','FEMALE')
        THEN 'Female'

    ELSE 'Unknown'

END

FROM bronze.erp_cust_az12;


/*
=============================================================
Step 8 : Validate Loaded Data
=============================================================

Purpose:
    Verify that the transformed ERP customer records
    have been successfully loaded into the Silver layer.

=============================================================
*/

SELECT *
FROM silver.erp_cust_az12;