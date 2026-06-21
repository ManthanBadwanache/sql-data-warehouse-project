# Data Warehouse Architecture

## Overview

This project implements a modern **Data Warehouse** using the **Medallion Architecture** pattern in PostgreSQL. The architecture is designed to ingest raw data from multiple source systems, progressively improve data quality through layered transformations, and expose business-ready data models for reporting and analytics.

The warehouse follows a layered approach consisting of **Bronze**, **Silver**, and **Gold** schemas, ensuring a clear separation between raw data, cleansed data, and analytical models.

---

# Architecture Overview

The overall architecture follows the data flow shown below:

```text
                    Source Systems
             ┌────────────────────────┐
             │                        │
             │   CRM CSV Files        │
             │   ERP CSV Files        │
             │                        │
             └────────────┬───────────┘
                          │
                          ▼
                 Bronze Layer (Raw Data)
                          │
                          ▼
             Silver Layer (Validated Data)
                          │
                          ▼
          Gold Layer (Business Data Model)
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼
     BI Dashboards   SQL Analytics   Machine Learning
```

---

# Medallion Architecture

The project follows the **Medallion Architecture**, a layered data design pattern widely adopted in modern Data Engineering.

## Bronze Layer

### Purpose

The Bronze layer stores data exactly as it is received from the source systems.

### Characteristics

* Raw data ingestion
* No business transformations
* Preserves original schema
* Historical source data
* Source-oriented design

### Schema

```text
bronze
```

### Source Tables

* crm_cust_info
* crm_prd_info
* crm_sales_details
* erp_cust_az12
* erp_loc_a101
* erp_px_cat_g1v2

---

## Silver Layer

### Purpose

The Silver layer stores cleansed, validated, and standardized data.

### Transformations Performed

* Duplicate removal
* Data validation
* Null handling
* Data type conversion
* Data standardization
* Business rule implementation
* Data quality improvements

### Schema

```text
silver
```

---

## Gold Layer

### Purpose

The Gold layer provides business-ready data models optimized for reporting and analytical workloads.

### Data Model

The Gold layer follows a **Star Schema**, consisting of:

* Dimension Views
* Fact Views

### Business Objects

* dim_customers
* dim_products
* fact_sales

### Schema

```text
gold
```

---

# Source Systems

The warehouse integrates data from two independent business systems.

## CRM System

Contains operational customer, product, and sales information.

### Tables

* crm_cust_info
* crm_prd_info
* crm_sales_details

---

## ERP System

Contains reference and master data used to enrich CRM information.

### Tables

* erp_cust_az12
* erp_loc_a101
* erp_px_cat_g1v2

---

# Data Integration

Customer and product data are integrated from multiple source systems before being exposed to analytical users.

Examples include:

* Customer demographic enrichment
* Country standardization
* Product category enrichment
* Surrogate key generation
* Dimension lookups

---

# Star Schema

The Gold layer follows a dimensional model.

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

This model enables efficient analytical queries while minimizing data redundancy.

---

# Data Flow

The high-level data flow is illustrated below.

```text
CSV Files
    │
    ▼
Bronze Layer
    │
    ▼
Silver Layer
    │
    ▼
Gold Layer
    │
    ▼
Business Analytics
```

---

# Data Consumers

The Gold layer is designed for downstream analytical applications.

Typical consumers include:

* Business Intelligence Dashboards
* SQL Analytics
* Reporting
* Machine Learning Models
* Ad-hoc Business Queries

---

# Repository Structure

```text
DataWarehouse/
│
├── datasets/
├── docs/
├── sql/
├── procedures/
└── README.md
```

---

# Design Principles

This project follows several core Data Engineering principles:

* Layered Medallion Architecture
* Separation of raw and transformed data
* Data quality validation
* Dimensional modeling
* Star Schema design
* Consistent naming conventions
* Modular ETL implementation
* Reusable stored procedures
* Business-oriented analytical models

---

# Summary

This architecture provides a scalable and maintainable Data Warehouse implementation using PostgreSQL. By separating raw ingestion, transformation, and business presentation into distinct layers, the solution supports reliable analytics while maintaining clear data lineage and simplified maintenance.
