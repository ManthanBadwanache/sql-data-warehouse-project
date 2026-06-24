/*
=============================================================
Create Product Dimension
=============================================================

Description:
    This script creates the Product Dimension for the
    Gold layer by integrating CRM product data with
    ERP product category information.

Business Objectives:
    • Build a conformed product dimension.
    • Generate surrogate product keys.
    • Integrate product category hierarchy.
    • Filter historical product records.
    • Prepare product data for analytical reporting.

Source Tables:
    silver.crm_prd_info
    silver.erp_px_cat_g1v2

Target:
    gold.dim_products

=============================================================
*/


/*
=============================================================
Step 1 : Build Product Dimension
=============================================================

Purpose:
    Combine CRM product information with ERP
    product category data.

Business Rule:
    CRM product information is treated as the
    master data source.

=============================================================
*/

SELECT
	pi.prd_id,
	pi.cat_id,
	pi.prd_key,
	pi.prd_nm,
	pi.prd_cost,
	pi.prd_line,
	pi.prd_start_dt,
	pi.prd_end_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance

FROM silver.crm_prd_info AS pi

LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pi.cat_id = pc.id

WHERE pi.prd_end_dt IS NULL;


/*
=============================================================
Step 2 : Validate Active Product Records
=============================================================

Purpose:
    Verify that only active product records are
    included in the Product Dimension.

Business Rule:
    Historical product records are excluded by
    filtering products with a NULL end date.

=============================================================
*/

SELECT
	COUNT(*)

FROM silver.crm_prd_info AS pi

LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pi.cat_id = pc.id

WHERE pi.prd_end_dt IS NULL

GROUP BY pi.prd_end_dt;


/*
=============================================================
Step 3 : Validate Product Uniqueness
=============================================================

Purpose:
    Verify that each product appears only once
    in the Product Dimension.

Expected Result:
    No duplicate product numbers.

=============================================================
*/

SELECT
	COUNT(*),
	prd_key

FROM
(
	SELECT
		pi.prd_id,
		pi.cat_id,
		pi.prd_key,
		pi.prd_nm,
		pi.prd_cost,
		pi.prd_line,
		pi.prd_start_dt,
		pi.prd_end_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance

	FROM silver.crm_prd_info AS pi

	LEFT JOIN silver.erp_px_cat_g1v2 AS pc
	ON pi.cat_id = pc.id

	WHERE pi.prd_end_dt IS NULL

)

GROUP BY prd_key

HAVING COUNT(*) > 1;


/*
=============================================================
Step 4 : Generate Product Dimension
=============================================================

Purpose:
    Generate the final Product Dimension by
    assigning surrogate keys and combining
    product attributes with category information.

=============================================================
*/

SELECT

	ROW_NUMBER() OVER
	(
		ORDER BY
			pi.prd_key,
			pi.prd_start_dt
	) AS product_key,

	pi.prd_id
	AS product_id,

	pi.prd_key
	AS product_number,

	pi.prd_nm
	AS product_name,

	pi.prd_cost
	AS product_cost,

	pi.cat_id
	AS category_id,

	pc.cat
	AS category,

	pc.subcat
	AS subcategory,

	pc.maintenance
	AS maintenance,

	pi.prd_line
	AS product_line,

	pi.prd_start_dt
	AS product_start_date

FROM silver.crm_prd_info AS pi

LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pi.cat_id = pc.id

WHERE pi.prd_end_dt IS NULL;


/*
=============================================================
Step 5 : Create Product Dimension View
=============================================================

Purpose:
    Publish the Product Dimension to the Gold
    layer for analytical reporting.

=============================================================
*/

CREATE VIEW gold.dim_products AS

SELECT

	ROW_NUMBER() OVER
	(
		ORDER BY
			pi.prd_key,
			pi.prd_start_dt
	) AS product_key,

	pi.prd_id
	AS product_id,

	pi.prd_key
	AS product_number,

	pi.prd_nm
	AS product_name,

	pi.prd_cost
	AS product_cost,

	pi.cat_id
	AS category_id,

	pc.cat
	AS category,

	pc.subcat
	AS subcategory,

	pc.maintenance
	AS maintenance,

	pi.prd_line
	AS product_line,

	pi.prd_start_dt
	AS product_start_date

FROM silver.crm_prd_info AS pi

LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pi.cat_id = pc.id

WHERE pi.prd_end_dt IS NULL;


/*
=============================================================
Step 6 : Validate Product Dimension
=============================================================

Purpose:
    Verify that the Product Dimension has been
    successfully created.

=============================================================
*/

SELECT *
FROM gold.dim_products;