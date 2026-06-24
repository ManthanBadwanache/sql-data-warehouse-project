/*
=============================================================
Stored Procedure : Load Gold Layer
=============================================================

Description:
    This stored procedure recreates all Gold Layer views
    using the cleansed data available in the Silver layer.

Objects Created:
    • gold.dim_customers
    • gold.dim_products
    • gold.fact_sales

Usage:
    CALL gold.load_gold();

=============================================================
*/

CREATE OR REPLACE PROCEDURE gold.load_gold()
LANGUAGE plpgsql
AS
$$
BEGIN

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Loading Gold Layer';
    RAISE NOTICE '===========================================';

    ---------------------------------------------------------
    -- Drop Existing Views
    ---------------------------------------------------------

    DROP VIEW IF EXISTS gold.fact_sales;
    DROP VIEW IF EXISTS gold.dim_products;
    DROP VIEW IF EXISTS gold.dim_customers;

    ---------------------------------------------------------
    -- Create Customer Dimension
    ---------------------------------------------------------

    RAISE NOTICE 'Creating gold.dim_customers...';

    CREATE VIEW gold.dim_customers AS

    SELECT
        ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
        ci.cst_id AS customer_id,
        ci.cst_key AS customer_number,
        ci.cst_first_name AS first_name,
        ci.cst_last_name AS last_name,
        loc.cntry AS country,
        ci.cst_marital_status AS marital_status,

        CASE
            WHEN ci.cst_gndr != 'Unknown'
                THEN ci.cst_gndr
            ELSE COALESCE(ca.gen,'Unknown')
        END AS gender,

        ca.bdate AS birthdate,
        ci.cst_create_date AS create_date

    FROM silver.crm_cust_info AS ci

    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid

    LEFT JOIN silver.erp_loc_a101 AS loc
        ON ci.cst_key = loc.cid;

    RAISE NOTICE 'gold.dim_customers Created Successfully';

    ---------------------------------------------------------
    -- Create Product Dimension
    ---------------------------------------------------------

    RAISE NOTICE 'Creating gold.dim_products...';

    CREATE VIEW gold.dim_products AS

    SELECT

        ROW_NUMBER() OVER
        (
            ORDER BY
            pi.prd_key,
            pi.prd_start_dt
        ) AS product_key,

        pi.prd_id AS product_id,
        pi.prd_key AS product_number,
        pi.prd_nm AS product_name,
        pi.prd_cost AS product_cost,
        pi.cat_id AS category_id,
        pc.cat AS category,
        pc.subcat AS subcategory,
        pc.maintenance AS maintenance,
        pi.prd_line AS product_line,
        pi.prd_start_dt AS product_start_date

    FROM silver.crm_prd_info AS pi

    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
        ON pi.cat_id = pc.id

    WHERE pi.prd_end_dt IS NULL;

    RAISE NOTICE 'gold.dim_products Created Successfully';

    ---------------------------------------------------------
    -- Create Sales Fact
    ---------------------------------------------------------

    RAISE NOTICE 'Creating gold.fact_sales...';

    CREATE VIEW gold.fact_sales AS

    SELECT

        sd.sls_ord_num AS order_number,

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

    RAISE NOTICE 'gold.fact_sales Created Successfully';

    ---------------------------------------------------------
    -- Completed
    ---------------------------------------------------------

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Gold Layer Loaded Successfully';
    RAISE NOTICE '===========================================';

EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE '===========================================';
        RAISE NOTICE 'Error Loading Gold Layer';
        RAISE NOTICE '%', SQLERRM;
        RAISE NOTICE '===========================================';

        RAISE;

END;
$$;

