/*
=============================================================
Create Customer Dimension
=============================================================

Description:
    This script creates the Customer Dimension for the
    Gold layer by integrating customer information from
    CRM and ERP systems.

Business Objectives:
    • Build a conformed customer dimension.
    • Generate surrogate customer keys.
    • Resolve conflicting customer attributes.
    • Prepare customer data for analytical reporting.

Source Tables:
    silver.crm_cust_info
    silver.erp_cust_az12
    silver.erp_loc_a101

Target:
    gold.dim_customers

=============================================================
*/


/*
=============================================================
Step 1 : Build Customer Dimension
=============================================================

Purpose:
    Combine CRM customer data with ERP customer
    demographic and location information.

Business Rule:
    CRM customer information is treated as the
    master data source.

=============================================================
*/

SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_first_name,
	ci.cst_last_name,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	loc.cntry

FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 AS loc
ON ci.cst_key = loc.cid;


/*
=============================================================
Step 2 : Validate Customer Uniqueness
=============================================================

Purpose:
    Verify that the resulting Customer Dimension
    contains one record per customer.

Expected Result:
    No duplicate customer IDs.

=============================================================
*/

SELECT
	cst_id,
	COUNT(*)

FROM
(
	SELECT
		ci.cst_id,
		ci.cst_key,
		ci.cst_first_name,
		ci.cst_last_name,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		loc.cntry

	FROM silver.crm_cust_info AS ci

	LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid

	LEFT JOIN silver.erp_loc_a101 AS loc
	ON ci.cst_key = loc.cid
)

GROUP BY cst_id

HAVING COUNT(*) > 1;


/*
=============================================================
Step 3 : Resolve Gender Conflicts
=============================================================

Purpose:
    Resolve conflicting gender values between
    CRM and ERP systems.

Business Rule:
    • CRM gender is treated as the primary source.
    • If CRM gender is Unknown,
      ERP gender is used.

=============================================================
*/

SELECT DISTINCT

	CASE

		WHEN ci.cst_gndr != 'Unknown'
		THEN ci.cst_gndr

		ELSE COALESCE(ca.gen,'Unknown')

	END AS new_gen

FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 AS loc
ON ci.cst_key = loc.cid;


/*
=============================================================
Step 4 : Generate Customer Dimension
=============================================================

Purpose:
    Generate the final Customer Dimension by
    assigning surrogate keys and combining all
    required business attributes.

=============================================================
*/

SELECT

	ROW_NUMBER() OVER (ORDER BY ci.cst_id)
	AS customer_key,

	ci.cst_id
	AS customer_id,

	ci.cst_key
	AS customer_number,

	ci.cst_first_name
	AS first_name,

	ci.cst_last_name
	AS last_name,

	loc.cntry
	AS country,

	ci.cst_marital_status
	AS marital_status,

	CASE

		WHEN ci.cst_gndr != 'Unknown'
		THEN ci.cst_gndr

		ELSE COALESCE(ca.gen,'Unknown')

	END
	AS gender,

	ca.bdate
	AS birthdate,

	ci.cst_create_date
	AS create_date

FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 AS loc
ON ci.cst_key = loc.cid;


/*
=============================================================
Step 5 : Create Customer Dimension View
=============================================================

Purpose:
    Publish the Customer Dimension to the Gold
    layer for analytical reporting.

=============================================================
*/

CREATE VIEW gold.dim_customers AS

SELECT

	ROW_NUMBER() OVER (ORDER BY ci.cst_id)
	AS customer_key,

	ci.cst_id
	AS customer_id,

	ci.cst_key
	AS customer_number,

	ci.cst_first_name
	AS first_name,

	ci.cst_last_name
	AS last_name,

	loc.cntry
	AS country,

	ci.cst_marital_status
	AS marital_status,

	CASE

		WHEN ci.cst_gndr != 'Unknown'
		THEN ci.cst_gndr

		ELSE COALESCE(ca.gen,'Unknown')

	END
	AS gender,

	ca.bdate
	AS birthdate,

	ci.cst_create_date
	AS create_date

FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 AS loc
ON ci.cst_key = loc.cid;


/*
=============================================================
Step 6 : Validate Customer Dimension
=============================================================

Purpose:
    Verify that the Customer Dimension has been
    successfully created.

=============================================================
*/



