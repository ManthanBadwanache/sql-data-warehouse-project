# ETL Workflow

## Overview

This document describes the **Extract, Transform, Load (ETL)** workflow implemented in the Data Warehouse project.

The ETL pipeline follows the **Medallion Architecture**, where data progressively moves through the **Bronze**, **Silver**, and **Gold** layers before becoming available for analytical consumption.

---

# ETL Pipeline

The complete ETL workflow is illustrated below.

```text
                 CSV Source Files
                        │
                        ▼
          ┌─────────────────────────┐
          │     Bronze Layer        │
          │  (Raw Data Ingestion)   │
          └─────────────────────────┘
                        │
                        ▼
          ┌─────────────────────────┐
          │     Silver Layer        │
          │ Data Cleansing & ETL    │
          └─────────────────────────┘
                        │
                        ▼
          ┌─────────────────────────┐
          │      Gold Layer         │
          │ Business Data Models    │
          └─────────────────────────┘
                        │
        ┌───────────────┼────────────────┐
        ▼               ▼                ▼
 Business Reports   SQL Analytics   Machine Learning
```

---

# ETL Execution Sequence

The warehouse is loaded in three sequential stages.

```text
Bronze Layer
      │
      ▼
Silver Layer
      │
      ▼
Gold Layer
```

Each layer depends on the successful completion of the previous layer.

---

# Bronze Layer

## Objective

The Bronze layer serves as the landing zone for raw source data.

No business transformations are performed in this layer.

---

## Input

CSV files exported from operational systems.

### CRM

* Customer Information
* Product Information
* Sales Information

### ERP

* Customer Information
* Customer Locations
* Product Categories

---

## Operations

* Create schemas
* Create raw tables
* Import CSV files
* Preserve source data

---

## Stored Procedure

```sql
CALL bronze.load_bronze();
```

---

## Output

Raw PostgreSQL tables inside the **bronze** schema.

---

# Manual Data Import

The current implementation uses **pgAdmin Import/Export Data** to load CSV files into the Bronze layer.

Because PostgreSQL stored procedures cannot invoke pgAdmin's import wizard, this step is performed manually during development.

Once data ingestion is automated (for example using PostgreSQL COPY, Python, Airflow, or another orchestration tool), this manual step can be removed.

---

# Silver Layer

## Objective

Transform raw operational data into clean, validated, and standardized datasets.

---

## Input

Bronze tables.

---

## Transformations

The Silver layer performs several data quality operations including:

* Duplicate removal
* NULL handling
* Data validation
* Data standardization
* Data type conversion
* Date validation
* Business rule implementation
* Data enrichment

---

## Transformation Scripts

CRM

* transform_crm_customers.sql
* transform_crm_products.sql
* transform_crm_sales.sql

ERP

* transform_erp_customers.sql
* transform_erp_locations.sql
* transform_erp_categories.sql

---

## Stored Procedure

```sql
CALL silver.load_silver();
```

---

## Output

Validated and standardized tables stored in the **silver** schema.

---

# Gold Layer

## Objective

Create business-ready analytical models.

The Gold layer follows a **Star Schema** design consisting of dimensions and fact tables.

---

## Input

Silver tables.

---

## Business Models

### Dimensions

* dim_customers
* dim_products

### Facts

* fact_sales

---

## Operations

* Build Customer Dimension
* Build Product Dimension
* Perform Dimension Lookups
* Generate Surrogate Keys
* Create Sales Fact View

---

## Stored Procedure

```sql
CALL gold.load_gold();
```

---

## Output

Business-ready analytical views stored in the **gold** schema.

---

# Master ETL Procedure

The project includes a master orchestration procedure.

```sql
CALL run_etl();
```

This procedure coordinates execution of the ETL pipeline.

Current development workflow:

1. Execute Bronze procedure.
2. Import CSV files using pgAdmin.
3. Execute Silver procedure.
4. Execute Gold procedure.

Future implementations can automate the complete workflow by integrating PostgreSQL COPY, Python, Airflow, or another orchestration tool.

---

# Data Quality Validation

Data quality checks are performed throughout the Silver layer.

Examples include:

* Primary key validation
* Duplicate detection
* Data type validation
* NULL value handling
* Date validation
* Business rule enforcement
* Referential integrity validation
* Standardization of categorical values

---

# Data Modeling

The Gold layer implements a **Star Schema**.

```text
                dim_customers
                       │
                       │
                customer_key
                       │
                       ▼

                 fact_sales

                       ▲
                       │
                 product_key
                       │
                       │
                 dim_products
```

The fact table stores transactional measures, while dimensions provide descriptive business context.

---

# ETL Folder Structure

```text
sql/
│
├── bronze/
│
├── silver/
│
├── gold/
│
├── procedures/
│
└── logging/
```

---

# Future Enhancements

The current ETL workflow is designed to be extensible.

Potential improvements include:

* Automated CSV ingestion using PostgreSQL COPY
* Apache Airflow workflow orchestration
* Incremental loading
* Change Data Capture (CDC)
* ETL logging and monitoring
* Cloud deployment
* Scheduled ETL execution
* Data quality dashboards

---

# Summary

The ETL pipeline follows a structured, layered approach that separates raw data ingestion, data transformation, and analytical modeling.

This architecture ensures:

* Reliable data quality
* Clear data lineage
* Modular ETL development
* Maintainable SQL code
* Business-ready analytical models
* Scalable warehouse design
