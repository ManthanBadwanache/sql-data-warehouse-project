CREATE TABLE IF NOT EXISTS silver.crm_cust_info (
	cst_id 				INT,
	cst_key 			VARCHAR(15),
	cst_first_name  	VARCHAR(50),
	cst_last_name 		VARCHAR(50),
	cst_marital_status 	VARCHAR(10),
	cst_gndr 			VARCHAR(10),
	cst_create_date 	DATE,
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE IF NOT EXISTS silver.crm_prd_info (
    prd_id 			INT,
	cat_id          VARCHAR(50),
    prd_key         VARCHAR(50),
    prd_nm	        VARCHAR(50),
    prd_cost        INT,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE silver.crm_prd_info ;
-- WE DROPPED AND MATCHED THE SCHEMA WE CREATED WHILE TRANSFORMING THE DATA IN THE BRONZE LAYER


CREATE TABLE IF NOT EXISTS silver.crm_sales_details(
	sls_ord_num  	VARCHAR(50),
	sls_prd_key  	VARCHAR(50),
	sls_cust_id 	INT,
	sls_order_dt 	INT,
	sls_ship_dt 	INT,
	sls_due_dt 		INT,
	sls_sales 		INT,
	sls_quantity 	INT,
	sls_price 		INT,
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	
);
-- Ensure the Schema matches the transformed data schema
DROP TABLE silver.crm_sales_details;

-- This schema matches our transformed data schema
CREATE TABLE IF NOT EXISTS silver.crm_sales_details(
	sls_ord_num  	VARCHAR(50),
	sls_prd_key  	VARCHAR(50),
	sls_cust_id 	INT,
	sls_order_dt 	DATE,
	sls_ship_dt 	DATE,
	sls_due_dt 		DATE,
	sls_sales 		INT,
	sls_quantity 	INT,
	sls_price 		INT,
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	
);


CREATE TABLE IF NOT EXISTS silver.erp_loc_a101(
	cid 		VARCHAR(50),
	cntry 		VARCHAR(50),
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS silver.erp_cust_az12(
	cid 	VARCHAR(50),
	bdate 	DATE,
	gen 	VARCHAR(50),
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS silver.erp_px_cat_g1v2(
	id 				VARCHAR(50),
	cat 			VARCHAR(50),
	subcat 			VARCHAR(50),
	maintenance 	VARCHAR(50),
	dwh_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*Adding data into the tables
If you're using pgAdmin (recommended)

Don't use COPY.

Instead:

Right-click the table bronze.crm_cust_info.
Select Import/Export Data...
Set:
Import
Filename: Browse to cust_info.csv
Format: CSV
Header: ✔
Click OK.

*/