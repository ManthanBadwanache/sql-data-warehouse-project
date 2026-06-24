/*
=============================================================
Stored Procedure : Run Complete ETL Pipeline
=============================================================

Description:
    This stored procedure orchestrates the complete
    Data Warehouse ETL pipeline.

Execution Flow:
    1. Load Bronze Layer
    2. Import CSV files into Bronze Layer (Manual Step)
    3. Load Silver Layer
    4. Load Gold Layer

Development Notice:
    This project currently uses pgAdmin's Import/Export
    Data feature to load CSV files into the Bronze layer.
    Since PostgreSQL stored procedures cannot execute
    pgAdmin's Import/Export wizard, the ETL pipeline
    requires a manual data import after the Bronze layer
    is prepared.

    Once the Bronze loading process is automated using
    PostgreSQL COPY, Python, Airflow, SSIS, Azure Data
    Factory, or another ETL orchestration tool, the
    commented procedure calls for the Silver and Gold
    layers can be enabled to achieve a fully automated
    end-to-end ETL pipeline.

Usage:
    CALL run_etl();

=============================================================
*/

---------------------------------------------------------
-- DEVELOPMENT NOTE
---------------------------------------------------------
-- The following procedure calls are intentionally
-- commented out because the Bronze layer data import
-- is currently performed manually using pgAdmin.
---------------------------------------------------------

CREATE OR REPLACE PROCEDURE run_etl()
LANGUAGE plpgsql
AS
$$
BEGIN

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Starting Data Warehouse ETL Pipeline';
    RAISE NOTICE '===========================================';

    ---------------------------------------------------------
    -- Bronze Layer
    ---------------------------------------------------------

    RAISE NOTICE 'Executing Bronze Layer...';

    CALL bronze.load_bronze();

    RAISE NOTICE '';
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'IMPORTANT';
    RAISE NOTICE 'Import all CSV files into the Bronze Layer';
    RAISE NOTICE 'using pgAdmin Import/Export Data.';
    RAISE NOTICE 'After the import is complete,';
    RAISE NOTICE 'execute the following procedures:';
    RAISE NOTICE '';
    RAISE NOTICE 'CALL silver.load_silver();';
    RAISE NOTICE 'CALL gold.load_gold();';
    RAISE NOTICE '===========================================';

    /*
    CALL silver.load_silver();

    CALL gold.load_gold();
    */

    RAISE NOTICE '';
    RAISE NOTICE 'ETL Pipeline Completed.';
    RAISE NOTICE '';

EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE '===========================================';
        RAISE NOTICE 'ETL Pipeline Failed';
        RAISE NOTICE '%', SQLERRM;
        RAISE NOTICE '===========================================';

        RAISE;

END;
$$;