/*
=============================================================
Stored Procedure : Load Bronze Layer
=============================================================

Description:
    This stored procedure performs a full refresh of the
    Bronze layer by truncating all Bronze tables.

    Note:
    Since PostgreSQL stored procedures cannot invoke
    pgAdmin's Import/Export wizard, CSV files must be
    imported manually after executing this procedure.

Usage:
    CALL bronze.load_bronze();

=============================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS
$$
BEGIN

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '===========================================';

    RAISE NOTICE 'Truncating bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE 'Truncating bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE 'Truncating bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE 'Truncating bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE 'Truncating bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE 'Truncating bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '';
    RAISE NOTICE 'Bronze tables truncated successfully.';
    RAISE NOTICE '';
    RAISE NOTICE 'Please import the following CSV files using';
    RAISE NOTICE 'pgAdmin Import/Export Data:';
    RAISE NOTICE '';
    RAISE NOTICE '  • crm_cust_info.csv';
    RAISE NOTICE '  • crm_prd_info.csv';
    RAISE NOTICE '  • crm_sales_details.csv';
    RAISE NOTICE '  • erp_cust_az12.csv';
    RAISE NOTICE '  • erp_loc_a101.csv';
    RAISE NOTICE '  • erp_px_cat_g1v2.csv';
    RAISE NOTICE '';
    RAISE NOTICE 'Bronze Layer Ready.';

EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE 'Error while loading Bronze Layer.';
        RAISE NOTICE '%', SQLERRM;

        RAISE;
END;
$$;