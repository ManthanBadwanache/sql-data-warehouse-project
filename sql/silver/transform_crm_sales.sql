/*
=============================================================
Transform CRM Sales Information
=============================================================

Description:
    This script performs data validation, cleansing and
    transformation on CRM sales transaction data before
    loading it into the Silver layer.

Business Objectives:
    • Validate referential integrity.
    • Standardize date values.
    • Correct invalid sales amounts.
    • Correct invalid product prices.
    • Improve transaction data quality.
    • Load cleansed data into the Silver layer.

Source Table:
    bronze.crm_sales_details

Target Table:
    silver.crm_sales_details

=============================================================
*/


/*
=============================================================
Step 1 : Review Source Data
=============================================================
Purpose:
    Review raw sales transaction data prior to
    transformation.

=============================================================
*/

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details;


/*
=============================================================
Step 2 : Validate Unwanted Spaces
=============================================================
Purpose:
    Detect leading and trailing spaces within
    order numbers.

Expected Result:
    No records returned.

=============================================================
*/

SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


/*
=============================================================
Step 3 : Validate Product Integration
=============================================================
Purpose:
    Verify that every product key exists in the
    Product Dimension source.

Expected Result:
    No records returned.

=============================================================
*/

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN
(
	SELECT prd_key
	FROM silver.crm_prd_info
);


/*
=============================================================
Step 4 : Validate Customer Integration
=============================================================
Purpose:
    Verify that every customer exists in the
    Customer Dimension source.

Expected Result:
    No records returned.

=============================================================
*/

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN
(
	SELECT cst_id
	FROM silver.crm_cust_info
);


/*
=============================================================
Step 5 : Validate Order Dates
=============================================================
Purpose:
    Identify invalid order dates.

Validation Rules:
    • Date cannot be less than or equal to zero.
    • Date must contain exactly 8 digits.
    • Date must be within the expected business range.

=============================================================
*/

SELECT
	NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LENGTH(sls_order_dt::TEXT) <> 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19900101;


/*
=============================================================
Step 6 : Convert Integer Dates
=============================================================
Purpose:
    Convert integer date fields into PostgreSQL DATE
    datatype while replacing invalid values with NULL.

=============================================================
*/

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,

	CASE
		WHEN sls_order_dt <= 0
			 OR LENGTH(sls_order_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_order_dt::TEXT,'YYYYMMDD')
	END AS sls_order_dt,

	CASE
		WHEN sls_ship_dt <= 0
			 OR LENGTH(sls_ship_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD')
	END AS sls_ship_dt,

	CASE
		WHEN sls_due_dt <= 0
			 OR LENGTH(sls_due_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
	END AS sls_due_dt,

	sls_sales,
	sls_quantity,
	sls_price

FROM bronze.crm_sales_details

WHERE sls_order_dt > sls_ship_dt
OR sls_ship_dt > sls_due_dt;

/*
=============================================================
Step 7 : Validate Sales Consistency
=============================================================

Purpose:
    Validate the relationship between Sales, Quantity
    and Price.

Business Rule:
    Sales = Quantity × Price

Validation Rules:
    • Sales must not be NULL.
    • Quantity must not be NULL.
    • Price must not be NULL.
    • Sales must be greater than zero.
    • Quantity must be greater than zero.
    • Price must be greater than zero.
    • Sales must equal Quantity × Price.

=============================================================
*/

SELECT DISTINCT
		sls_sales,
		sls_quantity,
		sls_price
FROM bronze.crm_sales_details

WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL

ORDER BY
	sls_sales,
	sls_quantity,
	sls_price;


/*
=============================================================
Step 8 : Correct Invalid Sales and Price Values
=============================================================

Purpose:
    Correct invalid sales amounts and product prices
    using predefined business rules.

Business Rules:
    • If Sales is invalid, recalculate using:
        Quantity × ABS(Price)

    • If Price is invalid, recalculate using:
        Sales / Quantity

=============================================================
*/

SELECT DISTINCT

		sls_sales AS old_sls_sales,

		sls_quantity,

		sls_price AS old_sls_price,

		CASE
			WHEN sls_sales IS NULL
				OR sls_sales <= 0
				OR sls_sales != sls_quantity * sls_price

			THEN sls_quantity * ABS(sls_price)

			ELSE sls_price

		END AS sls_sales,

		CASE
			WHEN sls_price IS NULL
				OR sls_price <= 0

			THEN sls_sales / NULLIF(sls_quantity,0)

			ELSE sls_price

		END AS sls_price

FROM bronze.crm_sales_details

ORDER BY
	sls_sales,
	sls_quantity,
	sls_price;


/*
=============================================================
Step 9 : Build Final Transformation
=============================================================

Purpose:
    Combine all validation and transformation rules
    into a single production-ready query.

Transformation Rules:
    • Convert integer dates into DATE datatype.
    • Replace invalid dates with NULL.
    • Correct invalid sales values.
    • Correct invalid price values.

=============================================================
*/

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,

	CASE
		WHEN sls_order_dt <= 0
			OR LENGTH(sls_order_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_order_dt::TEXT,'YYYYMMDD')
	END AS sls_order_dt,

	CASE
		WHEN sls_ship_dt <= 0
			OR LENGTH(sls_ship_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD')
	END AS sls_ship_dt,

	CASE
		WHEN sls_due_dt <= 0
			OR LENGTH(sls_due_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
	END AS sls_due_dt,

	CASE
		WHEN sls_sales IS NULL
			OR sls_sales <= 0
			OR sls_sales != sls_quantity * sls_price

		THEN sls_quantity * ABS(sls_price)

		ELSE sls_price

	END AS sls_sales,

	sls_quantity,

	CASE
		WHEN sls_price IS NULL
			OR sls_price <= 0

		THEN sls_sales / NULLIF(sls_quantity,0)

		ELSE sls_price

	END AS sls_price

FROM bronze.crm_sales_details;


/*
=============================================================
Step 10 : Load Data into Silver Layer
=============================================================

Purpose:
    Load the transformed CRM sales data into the
    Silver layer.

Target:
    silver.crm_sales_details

=============================================================
*/

INSERT INTO silver.crm_sales_details
(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,

	CASE
		WHEN sls_order_dt <= 0
			OR LENGTH(sls_order_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_order_dt::TEXT,'YYYYMMDD')
	END AS sls_order_dt,

	CASE
		WHEN sls_ship_dt <= 0
			OR LENGTH(sls_ship_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD')
	END AS sls_ship_dt,

	CASE
		WHEN sls_due_dt <= 0
			OR LENGTH(sls_due_dt::TEXT) <> 8
		THEN NULL
		ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
	END AS sls_due_dt,

	CASE
		WHEN sls_sales IS NULL
			OR sls_sales <= 0
			OR sls_sales != sls_quantity * sls_price

		THEN sls_quantity * ABS(sls_price)

		ELSE sls_price

	END AS sls_sales,

	sls_quantity,

	CASE
		WHEN sls_price IS NULL
			OR sls_price <= 0

		THEN sls_sales / NULLIF(sls_quantity,0)

		ELSE sls_price

	END AS sls_price

FROM bronze.crm_sales_details;


/*
=============================================================
Step 11 : Validate Loaded Data
=============================================================

Purpose:
    Verify that the transformed CRM sales records have
    been successfully loaded into the Silver layer.

=============================================================
*/

SELECT *
FROM silver.crm_sales_details;