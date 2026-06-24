/*
=============================================================
Create Sales Fact Table
=============================================================

Description:
    This script creates the Sales Fact table for the
    Gold layer by integrating sales transactions with
    the Customer and Product dimensions.

Business Objectives:
    • Build the central fact table for the Star Schema.
    • Replace business keys with surrogate keys.
    • Preserve transactional measures.
    • Prepare sales data for analytical reporting.

Source Tables:
    silver.crm_sales_details
    gold.dim_customers
    gold.dim_products

Target:
    gold.fact_sales

=============================================================
*/


/*
=============================================================
Step 1 : Review Sales Transactions
=============================================================

Purpose:
    Review the cleansed sales transaction data
    available in the Silver layer.

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
FROM silver.crm_sales_details;


/*
=============================================================
Step 2 : Perform Dimension Lookup
=============================================================

Purpose:
    Replace business keys with surrogate keys by
    joining the Sales transactions with the
    Product and Customer dimensions.

Business Rule:
    • Product Number → Product Key
    • Customer ID → Customer Key

=============================================================
*/

SELECT
	sls_ord_num AS order_number,

	dp.product_key,

	dc.customer_key,

	sd.sls_order_dt AS order_date,

	sd.sls_ship_dt AS shipping_date,

	sd.sls_due_dt AS due_date,

	sd.sls_sales AS sales_amount,

	sd.sls_quantity AS quantity,

	sd.sls_price AS price

FROM silver.crm_sales_details AS sd

LEFT JOIN gold.dim_products AS dp
ON sd.sls_prd_key = dp.product_number

LEFT JOIN gold.dim_customers AS dc
ON sd.sls_cust_id = dc.customer_id;


/*
=============================================================
Step 3 : Create Sales Fact View
=============================================================

Purpose:
    Publish the Sales Fact table to the Gold
    layer as the central fact table within
    the Star Schema.

=============================================================
*/

CREATE VIEW gold.fact_sales AS

SELECT
	sls_ord_num AS order_number,

	dp.product_key,

	dc.customer_key,

	sd.sls_order_dt AS order_date,

	sd.sls_ship_dt AS shipping_date,

	sd.sls_due_dt AS due_date,

	sd.sls_sales AS sales_amount,

	sd.sls_quantity AS quantity,

	sd.sls_price AS price

FROM silver.crm_sales_details AS sd

LEFT JOIN gold.dim_products AS dp
ON sd.sls_prd_key = dp.product_number

LEFT JOIN gold.dim_customers AS dc
ON sd.sls_cust_id = dc.customer_id;


/*
=============================================================
Step 4 : Validate Sales Fact Table
=============================================================

Purpose:
    Verify that the Sales Fact view has been
    successfully created.

=============================================================
*/

SELECT *
FROM gold.fact_sales;


/*
=============================================================
Step 5 : Validate Referential Integrity
=============================================================

Purpose:
    Verify that every sales transaction is
    successfully linked to both the Customer
    and Product dimensions.

Expected Result:
    No records returned.

=============================================================
*/

SELECT *

FROM gold.fact_sales AS fs

LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key

LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key

WHERE dc.customer_key IS NULL
OR dp.product_key IS NULL;