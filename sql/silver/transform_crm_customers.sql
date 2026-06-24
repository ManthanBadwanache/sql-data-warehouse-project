/*
=============================================================
Transform CRM Customer Information
=============================================================

Description:
    This script performs data cleansing and transformation
    on CRM customer data before loading it into the Silver
    layer.

Business Objectives:
    • Ensure customer uniqueness.
    • Remove duplicate customer records.
    • Standardize customer attributes.
    • Improve data quality.
    • Load cleansed data into the Silver layer.

Source Table:
    bronze.crm_cust_info

Target Table:
    silver.crm_cust_info

=============================================================
*/


/*
=============================================================
Step 1 : Validate Primary Key
=============================================================
Purpose:
    Verify that the primary key (cst_id) does not contain
    duplicate records.

Expected Result:
    No duplicate customer IDs.

=============================================================
*/

SELECT
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


/*
=============================================================
Step 2 : Inspect Duplicate Records
=============================================================
Purpose:
    Investigate duplicate customer records.

Business Rule:
    If duplicate records exist, retain the most recent
    customer record based on cst_create_date.

=============================================================
*/

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;


/*
=============================================================
Step 3 : Remove Duplicate Records
=============================================================
Purpose:
    Rank duplicate customer records and keep only the
    latest record using ROW_NUMBER().

=============================================================
*/

SELECT *
FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS flag_last

    FROM bronze.crm_cust_info

) ranked_customers

WHERE flag_last = 1;


/*
=============================================================
Step 4 : Validate Unwanted Spaces
=============================================================
Purpose:
    Detect leading or trailing spaces within customer
    attributes.

Expected Result:
    No records should be returned.

=============================================================
*/

SELECT
    cst_last_name
FROM bronze.crm_cust_info
WHERE cst_last_name <> TRIM(cst_last_name);


SELECT
    cst_key
FROM bronze.crm_cust_info
WHERE cst_key <> TRIM(cst_key);


SELECT
    cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status <> TRIM(cst_marital_status);


SELECT
    cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);


/*
=============================================================
Step 5 : Remove Unwanted Spaces
=============================================================
Purpose:
    Trim leading and trailing spaces from customer
    attributes.

=============================================================
*/

SELECT

    cst_id,

    cst_key,

    TRIM(cst_first_name) AS cst_first_name,

    TRIM(cst_last_name) AS cst_last_name,

    cst_marital_status,

    cst_gndr,

    cst_create_date

FROM
(
    SELECT *,

           ROW_NUMBER() OVER
           (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS flag_last

    FROM bronze.crm_cust_info

) ranked_customers

WHERE flag_last = 1;


/*
=============================================================
Step 6 : Analyze Marital Status
=============================================================
Purpose:
    Review existing marital status values before
    standardization.

=============================================================
*/

SELECT DISTINCT
    cst_marital_status
FROM bronze.crm_cust_info;


/*
=============================================================
Step 7 : Standardize Marital Status
=============================================================
Business Rule:

S → Single

M → Married

Others → Unknown

=============================================================
*/

SELECT

CASE

    WHEN UPPER(TRIM(cst_marital_status)) = 'S'
        THEN 'Single'

    WHEN UPPER(TRIM(cst_marital_status)) = 'M'
        THEN 'Married'

    ELSE 'Unknown'

END AS cst_marital_status

FROM bronze.crm_cust_info;

/*
=============================================================
Step 8 : Analyze Gender Values
=============================================================
Purpose:
    Review existing gender values before
    standardization.

=============================================================
*/

SELECT
CASE
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'Unknown'
END AS cst_gndr
FROM bronze.crm_cust_info;


/*
=============================================================
Step 9 : Build Final Transformation
=============================================================
Purpose:
    Combine all cleansing and transformation rules into a
    single production-ready query.

Transformation Rules:
    • Keep latest customer record.
    • Trim unwanted spaces.
    • Standardize marital status.
    • Standardize gender.

=============================================================
*/

SELECT
    cst_id,
    cst_key,
    TRIM(cst_first_name) AS cst_first_name,
    TRIM(cst_last_name) AS cst_last_name,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S'
            THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M'
            THEN 'Married'
        ELSE 'Unknown'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F'
            THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M'
            THEN 'Male'
        ELSE 'Unknown'
    END AS cst_gndr,

    cst_create_date

FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS flag_last

    FROM bronze.crm_cust_info

) ranked_customers

 WHERE flag_last=1 AND cst_id IS NOT NULL; 
 /*
 While validating the Gold layer, I discovered customer records with NULL business identifiers originating from the source CRM data. 
 These records propagated through the ETL because no validation rule existed . 
 I added a Silver layer data quality rule (cst_id IS NOT NULL) to exclude records with NULL customer IDs, ensuring that only valid customer entities were loaded into the analytical model.
 */


/*
=============================================================
Step 10 : Load Data into Silver Layer
=============================================================
Purpose:
    Insert the transformed customer records into the
    Silver layer.

Target:
    silver.crm_cust_info

=============================================================
*/

INSERT INTO silver.crm_cust_info
(
    cst_id,
    cst_key,
    cst_first_name,
    cst_last_name,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT
    cst_id,
    cst_key,
    TRIM(cst_first_name),
    TRIM(cst_last_name),

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S'
            THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M'
            THEN 'Married'
        ELSE 'Unknown'
    END,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F'
            THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M'
            THEN 'Male'
        ELSE 'Unknown'
    END,

    cst_create_date

FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS flag_last

    FROM bronze.crm_cust_info

) ranked_customers

WHERE flag_last = 1;


/*
=============================================================
Step 11 : Validate Loaded Data
=============================================================
Purpose:
    Verify that the transformed customer records have been
    successfully loaded into the Silver layer.

=============================================================
*/

SELECT *
FROM silver.crm_cust_info;