# /*

Purpose:
This script creates the Bronze layer tables used to store raw data
ingested from multiple source systems, including CRM and ERP.

The Bronze layer serves as the landing zone for source data and
preserves the original structure with little to no transformation.
These tables are intended for raw data ingestion only and provide the
foundation for downstream transformations in the Silver and Gold layers.

Source Systems:

* CRM (Customer Relationship Management)
* ERP (Enterprise Resource Planning)

Warning:

* Execute this script only after creating the 'bronze' schema.
* Bronze tables intentionally do not define primary keys, foreign keys,
  or other constraints to preserve the raw source data exactly as
  received from the source systems.
* Ensure the corresponding CSV files are available before loading data.
* When using pgAdmin, use the **Import/Export Data** feature to import
  CSV files. The SQL COPY command requires the PostgreSQL server to have
  access to the source files.

===============================================================================
*/

-- ============================================================================
-- CRM Customer Information
-- Stores raw customer master data extracted from the CRM system.
-- ============================================================================

CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
cst_id              INT,
cst_key             VARCHAR(15),
cst_first_name      VARCHAR(50),
cst_last_name       VARCHAR(50),
cst_marital_status  VARCHAR(10),
cst_gndr            VARCHAR(10),
cst_create_date     DATE
);

-- ============================================================================
-- CRM Product Information
-- Stores raw product master data extracted from the CRM system.
-- ============================================================================

CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
prd_id          INT,
prd_key         VARCHAR(50),
prd_nm          VARCHAR(50),
prd_cost        INT,
prd_line        VARCHAR(10),
prd_start_dt    DATE,
prd_end_dt      DATE
);

-- ============================================================================
-- CRM Sales Details
-- Stores raw sales transaction data extracted from the CRM system.
-- ============================================================================

CREATE TABLE IF NOT EXISTS bronze.crm_sales_details (
sls_ord_num     VARCHAR(50),
sls_prd_key     VARCHAR(50),
sls_cust_id     INT,
sls_order_dt    INT,
sls_ship_dt     INT,
sls_due_dt      INT,
sls_sales       INT,
sls_quantity    INT,
sls_price       INT
);

-- ============================================================================
-- ERP Customer Location
-- Stores customer location information extracted from the ERP system.
-- ============================================================================

CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
cid     VARCHAR(50),
cntry   VARCHAR(50)
);

-- ============================================================================
-- ERP Customer Demographics
-- Stores customer demographic information extracted from the ERP system.
-- ============================================================================

CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
cid     VARCHAR(50),
bdate   DATE,
gen     VARCHAR(50)
);

-- ============================================================================
-- ERP Product Categories
-- Stores product category and maintenance information extracted from the ERP system.
-- ============================================================================

CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
id              VARCHAR(50),
cat             VARCHAR(50),
subcat          VARCHAR(50),
maintenance     VARCHAR(50)
);
