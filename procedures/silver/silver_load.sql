/*
=============================================================
Stored Procedure : Load Silver Layer
=============================================================

Description:
    This stored procedure performs a full refresh of the
    Silver layer by truncating all Silver tables and
    executing all transformation logic from the Bronze layer.

Usage:
    CALL silver.load_silver();

=============================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS
$$
BEGIN

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '===========================================';

    ---------------------------------------------------------
    -- Truncate Silver Tables
    ---------------------------------------------------------

    RAISE NOTICE 'Truncating Silver Tables...';

    TRUNCATE TABLE silver.crm_sales_details;
    TRUNCATE TABLE silver.crm_prd_info;
    TRUNCATE TABLE silver.crm_cust_info;
    TRUNCATE TABLE silver.erp_loc_a101;
    TRUNCATE TABLE silver.erp_cust_az12;
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    ---------------------------------------------------------
    -- Load CRM Customers
    ---------------------------------------------------------

    RAISE NOTICE 'Loading CRM Customers...';

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
            WHEN UPPER(TRIM(cst_marital_status))='S'
                THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status))='M'
                THEN 'Married'
            ELSE 'Unknown'
        END,

        CASE
            WHEN UPPER(TRIM(cst_gndr))='F'
                THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr))='M'
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

    ) 

    WHERE flag_last=1 AND cst_id IS NOT NULL;;

    RAISE NOTICE 'CRM Customers Loaded Successfully';

    ---------------------------------------------------------
    -- Load CRM Products
    ---------------------------------------------------------

    RAISE NOTICE 'Loading CRM Products...';

    INSERT INTO silver.crm_prd_info
    (
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

        REPLACE
        (
            SUBSTRING(prd_key,1,5),
            '-',
            '_'
        ) AS cat_id,

        SUBSTRING(prd_key,7),

        prd_nm,

        COALESCE(prd_cost,0),

        prd_line,

        CAST(prd_start_dt AS DATE),

        CAST
        (
            LEAD(prd_start_dt)
            OVER
            (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            )
            - INTERVAL '1 day'
            AS DATE
        )

    FROM bronze.crm_prd_info;

    RAISE NOTICE 'CRM Products Loaded Successfully';

    ---------------------------------------------------------
    -- Load CRM Sales
    ---------------------------------------------------------

    RAISE NOTICE 'Loading CRM Sales...';

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
        END,

        CASE
            WHEN sls_ship_dt <= 0
                 OR LENGTH(sls_ship_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_due_dt <= 0
                 OR LENGTH(sls_due_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * sls_price
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price
        END

    FROM bronze.crm_sales_details;

    RAISE NOTICE 'CRM Sales Loaded Successfully';

    ---------------------------------------------------------
    -- Load ERP Customers
    ---------------------------------------------------------

    RAISE NOTICE 'Loading ERP Customers...';

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
            WHEN bdate > NOW()
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

    RAISE NOTICE 'ERP Customers Loaded Successfully';

    ---------------------------------------------------------
    -- Load ERP Locations
    ---------------------------------------------------------

    RAISE NOTICE 'Loading ERP Locations...';

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )

    SELECT
        REPLACE(cid,'-','') AS cid,

        CASE
            WHEN TRIM(cntry) IN ('US','USA')
                THEN 'United States'
            WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'
            WHEN cntry IS NULL
                 OR TRIM(cntry) = ''
                THEN 'N/A'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;

    RAISE NOTICE 'ERP Locations Loaded Successfully';

    ---------------------------------------------------------
    -- Load ERP Product Categories
    ---------------------------------------------------------

    RAISE NOTICE 'Loading ERP Product Categories...';

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

    RAISE NOTICE 'ERP Product Categories Loaded Successfully';

    ---------------------------------------------------------
    -- Silver Layer Completed
    ---------------------------------------------------------

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Silver Layer Loaded Successfully';
    RAISE NOTICE '===========================================';

EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE '===========================================';
        RAISE NOTICE 'Error Loading Silver Layer';
        RAISE NOTICE '%', SQLERRM;
        RAISE NOTICE '===========================================';

        RAISE;

END;
$$;


