/*
=============================================================
Transform ERP Product Category Information
=============================================================

Description:
    This script validates and loads ERP product category
    master data into the Silver layer.

Business Objectives:
    • Validate category identifiers.
    • Validate descriptive attributes.
    • Improve category master data quality.
    • Load validated data into the Silver layer.

Source Table:
    bronze.erp_px_cat_g1v2

Target Table:
    silver.erp_px_cat_g1v2

=============================================================
*/


/*
=============================================================
Step 1 : Review Source Data
=============================================================

Purpose:
    Review the raw ERP product category data before
    applying transformations.

=============================================================
*/

SELECT *
FROM bronze.erp_px_cat_g1v2;


/*
=============================================================
Step 2 : Validate Primary Key
=============================================================

Purpose:
    Verify that the category identifier does not
    contain duplicate or NULL values.

Expected Result:
    No duplicate or NULL category IDs.

=============================================================
*/

SELECT
	id,
	COUNT(*)
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
	OR id IS NULL;


/*
=============================================================
Step 3 : Validate Unwanted Spaces
=============================================================

Purpose:
    Detect leading and trailing spaces in category
    attributes.

Expected Result:
    No records returned.

=============================================================
*/

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE	id <> TRIM(id)
	OR cat <> TRIM(cat)
	OR subcat <> TRIM(subcat)
	OR maintenance <> TRIM(maintenance);


/*
=============================================================
Step 4 : Review Distinct Values
=============================================================

Purpose:
    Review category, subcategory and maintenance
    values prior to loading into the Silver layer.

=============================================================
*/

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;


/*
=============================================================
Step 5 : Build Final Transformation
=============================================================

Purpose:
    Prepare the validated ERP product category
    dataset for loading into the Silver layer.

=============================================================
*/

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;


/*
=============================================================
Step 6 : Load Data into Silver Layer
=============================================================

Purpose:
    Insert the validated ERP product category
    records into the Silver layer.

Target:
    silver.erp_px_cat_g1v2

=============================================================
*/

INSERT INTO silver.erp_px_cat_g1v2
(
	id,
	cat,
	subcat,
	maintenance
)

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;


/*
=============================================================
Step 7 : Validate Loaded Data
=============================================================

Purpose:
    Verify that the transformed ERP product category
    records have been successfully loaded into the
    Silver layer.

=============================================================
*/

SELECT *
FROM silver.erp_px_cat_g1v2;