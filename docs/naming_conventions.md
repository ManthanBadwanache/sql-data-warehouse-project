# Naming Conventions

## Overview

This document defines the naming standards used throughout the Data Warehouse project. Following consistent naming conventions improves readability, maintainability, and collaboration while ensuring that database objects are easy to identify and understand.

---

# General Principles

The following standards apply to all database objects.

* Use **snake_case** for all object names.
* Use **lowercase** letters only.
* Separate words using underscores (`_`).
* Use meaningful and descriptive names.
* Use English for all database objects.
* Avoid SQL reserved keywords.
* Keep naming consistent across all layers of the data warehouse.

---

# Schema Naming Convention

The project follows the **Medallion Architecture**, where each schema represents a stage of data processing.

| Schema   | Description                                                           |
| -------- | --------------------------------------------------------------------- |
| `bronze` | Stores raw data exactly as received from the source systems.          |
| `silver` | Stores cleansed, validated, and standardized data.                    |
| `gold`   | Stores business-ready dimensional models for reporting and analytics. |

---

# Table Naming Convention

## Bronze Layer

Bronze tables preserve the original structure and naming of the source systems.

### Pattern

```text
<source_system>_<entity>
```

### Components

* **source_system** – Name of the source application (e.g., `crm`, `erp`)
* **entity** – Original entity or table name from the source system

### Examples

```text
crm_cust_info
crm_prd_info
crm_sales_details

erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2
```

---

## Silver Layer

Silver tables retain the original table names while storing cleansed and standardized data.

### Pattern

```text
<source_system>_<entity>
```

### Examples

```text
crm_cust_info
crm_prd_info
crm_sales_details

erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2
```

---

## Gold Layer

Gold objects use business-friendly names instead of source-system names.

### Pattern

```text
<category>_<entity>
```

### Categories

| Prefix  | Description                           |
| ------- | ------------------------------------- |
| `dim_`  | Dimension tables                      |
| `fact_` | Fact tables                           |
| `agg_`  | Aggregated tables or reporting tables |

### Examples

```text
dim_customers
dim_products

fact_sales

agg_sales_monthly
agg_customer_summary
```

---

# View Naming Convention

Business views follow the same naming convention as Gold layer tables.

### Examples

```text
dim_customers

dim_products

fact_sales
```

---

# Column Naming Convention

Column names should clearly describe the business attribute they represent.

### Guidelines

* Use snake_case
* Avoid abbreviations whenever possible
* Use descriptive business names
* Keep names consistent across related tables

### Examples

```text
customer_id

customer_number

product_name

sales_amount

order_date
```

---

# Primary Key Naming Convention

Dimension tables use surrogate keys as their primary keys.

### Pattern

```text
<table_name>_key
```

### Examples

```text
customer_key

product_key
```

---

# Foreign Key Naming Convention

Fact tables reference surrogate keys from dimension tables.

### Pattern

```text
<referenced_table>_key
```

### Examples

```text
customer_key

product_key
```

---

# Technical Column Naming Convention

System-generated metadata columns use the prefix `dwh_`.

### Pattern

```text
dwh_<column_name>
```

### Examples

```text
dwh_create_datetime

dwh_load_datetime

dwh_last_updated
```

---

# Stored Procedure Naming Convention

Stored procedures responsible for loading data into each layer follow a consistent naming standard.

### Pattern

```text
load_<layer>
```

### Examples

```text
load_bronze

load_silver

load_gold
```

Master orchestration procedures should use descriptive names.

### Examples

```text
run_etl
```

---

# SQL File Naming Convention

SQL scripts are organized according to their purpose.

| Pattern                  | Purpose                                    |
| ------------------------ | ------------------------------------------ |
| `ddl_<layer>.sql`        | Create schemas and tables                  |
| `load_<layer>.sql`       | Load data into each layer                  |
| `transform_<entity>.sql` | Perform data validation and transformation |
| `dim_<entity>.sql`       | Create dimension views                     |
| `fact_<entity>.sql`      | Create fact views                          |

### Examples

```text
ddl_bronze.sql

load_bronze.sql

transform_crm_customers.sql

transform_crm_products.sql

transform_crm_sales.sql

dim_customers.sql

dim_products.sql

fact_sales.sql
```

---

# Logging Objects

Logging tables and procedures should use descriptive names that clearly identify their purpose.

### Examples

```text
etl_log

etl_logging.sql
```

---

# Summary

This project follows consistent PostgreSQL naming standards to ensure:

* Readable SQL code
* Consistent object naming
* Easy maintenance
* Scalable ETL development
* Business-friendly analytical models
* Enterprise-style project organization
