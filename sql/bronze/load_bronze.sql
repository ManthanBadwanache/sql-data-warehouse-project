/*
=============================================================
Load Data into Bronze Layer
=============================================================
Description:
    This script loads raw CSV files into the Bronze layer.
    Data is imported without any transformations.

Source:
    CRM System
    ERP System

Method:
    Import/Export Data (pgAdmin)

=============================================================
*/

-- ==========================================================
-- Load CRM Customer Information
-- ==========================================================

TRUNCATE TABLE bronze.crm_cust_info;

-- Import cust_info.csv using pgAdmin
-- Right Click Table -> Import/Export Data
-- Format : CSV
-- Header : TRUE


-- ==========================================================
-- Load CRM Product Information
-- ==========================================================

TRUNCATE TABLE bronze.crm_prd_info;

-- Import prd_info.csv


-- ==========================================================
-- Load CRM Sales Details
-- ==========================================================

TRUNCATE TABLE bronze.crm_sales_details;

-- Import sales_details.csv


-- ==========================================================
-- Load ERP Customer Information
-- ==========================================================

TRUNCATE TABLE bronze.erp_cust_az12;

-- Import CUST_AZ12.csv


-- ==========================================================
-- Load ERP Customer Locations
-- ==========================================================

TRUNCATE TABLE bronze.erp_loc_a101;

-- Import LOC_A101.csv


-- ==========================================================
-- Load ERP Product Categories
-- ==========================================================

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

-- Import PX_CAT_G1V2.csv


-- ==========================================================
-- Verify Bronze Layer
-- ==========================================================

SELECT COUNT(*) AS crm_customers
FROM bronze.crm_cust_info;

SELECT COUNT(*) AS crm_products
FROM bronze.crm_prd_info;

SELECT COUNT(*) AS crm_sales
FROM bronze.crm_sales_details;

SELECT COUNT(*) AS erp_customers
FROM bronze.erp_cust_az12;

SELECT COUNT(*) AS erp_locations
FROM bronze.erp_loc_a101;

SELECT COUNT(*) AS erp_categories
FROM bronze.erp_px_cat_g1v2;