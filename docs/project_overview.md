# Project Overview

## Executive Summary

This project demonstrates the design and implementation of a modern **Data Warehouse** using **PostgreSQL** following the **Medallion Architecture**. The solution integrates customer, product, and sales data from multiple operational systems into a centralized analytical repository.

The warehouse is organized into three logical layers—**Bronze**, **Silver**, and **Gold**—to separate raw data ingestion, data transformation, and business-ready analytical models. The final output is a dimensional model (Star Schema) designed for reporting, business intelligence, and future machine learning applications.

This project was built to simulate an enterprise Data Engineering workflow, emphasizing data quality, maintainability, and scalability rather than simply storing data.

---

# Project Objectives

The primary objectives of this project were to:

* Design a layered Data Warehouse using the Medallion Architecture.
* Integrate data from multiple source systems.
* Implement an ETL pipeline using PostgreSQL.
* Apply data cleansing and validation techniques.
* Build a dimensional model using a Star Schema.
* Demonstrate industry-standard Data Engineering practices.
* Produce business-ready datasets for analytics and reporting.

---

# Business Problem

Organizations often maintain data across multiple operational systems such as CRM and ERP platforms. Although these systems support day-to-day business operations, they are not optimized for analytical reporting.

Some common challenges include:

* Data stored across multiple systems.
* Inconsistent data formats.
* Duplicate records.
* Missing values.
* Lack of standardized business terminology.
* Complex reporting queries across operational databases.

This project addresses these challenges by consolidating data into a centralized Data Warehouse where information is cleaned, standardized, and modeled for efficient analytical querying.

---

# Solution Overview

The solution follows a layered architecture where each stage has a clearly defined responsibility.

## Bronze Layer

The Bronze layer serves as the landing zone for raw source data.

Responsibilities include:

* Store raw CSV data.
* Preserve source structure.
* Maintain historical records.
* Avoid business transformations.

---

## Silver Layer

The Silver layer focuses on data quality and standardization.

Transformations performed include:

* Duplicate removal
* Data validation
* NULL handling
* Date validation
* Standardization of categorical values
* Data type conversion
* Product and customer enrichment
* Business rule implementation

---

## Gold Layer

The Gold layer provides business-ready analytical models.

The warehouse exposes:

* Customer Dimension
* Product Dimension
* Sales Fact

using a **Star Schema** optimized for reporting and business intelligence.

---

# Technology Stack

| Technology | Purpose                                       |
| ---------- | --------------------------------------------- |
| PostgreSQL | Relational Database Management System         |
| PL/pgSQL   | Stored Procedures                             |
| SQL        | Data Definition, Transformation, and Querying |
| pgAdmin    | Database Administration and CSV Import        |
| Git        | Version Control                               |
| GitHub     | Source Code Management and Documentation      |

---

# Project Architecture

The Data Warehouse follows the Medallion Architecture.

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

Each layer performs a specific role while maintaining clear separation of responsibilities.

---

# Key Design Decisions

Several architectural decisions were made during development to improve maintainability and scalability.

## PostgreSQL Instead of SQL Server

Although the original learning material was based on SQL Server, PostgreSQL was selected as the implementation platform.

Reasons include:

* Open-source ecosystem.
* Cross-platform compatibility.
* Strong SQL standards compliance.
* Excellent support for advanced SQL features.
* Opportunity to learn PostgreSQL-specific ETL development.

---

## Medallion Architecture

The project adopts the Medallion Architecture because it provides:

* Clear separation of concerns.
* Improved data quality.
* Simplified maintenance.
* Scalable ETL workflows.
* Better support for analytical workloads.

---

## Star Schema

The Gold layer uses a Star Schema because it:

* Simplifies analytical queries.
* Improves reporting performance.
* Reduces query complexity.
* Supports Business Intelligence tools.

---

## Stored Procedures

The ETL pipeline is organized into reusable stored procedures.

Benefits include:

* Modular ETL execution.
* Simplified maintenance.
* Improved code organization.
* Reusable loading process.

---

# Data Quality Strategy

The Silver layer includes multiple validation and transformation steps.

Examples include:

* Duplicate detection
* Primary key validation
* Data standardization
* Date validation
* Missing value handling
* Business rule enforcement
* Dimension lookup preparation

These checks improve the reliability of analytical data exposed in the Gold layer.

---

# Documentation

The project includes comprehensive documentation to improve maintainability and knowledge sharing.

Documentation includes:

* Architecture
* ETL Workflow
* Naming Conventions
* Data Catalog

Each document focuses on a different aspect of the Data Warehouse implementation.

---

# Lessons Learned

Developing this project provided practical experience in several Data Engineering concepts.

Key learnings include:

* Designing a layered Data Warehouse.
* Implementing ETL pipelines.
* Applying data cleansing and validation techniques.
* Building dimensional models.
* Creating Star Schemas.
* Developing PostgreSQL stored procedures.
* Organizing SQL projects using modular folder structures.
* Writing technical documentation for data projects.

Additionally, implementing the project in PostgreSQL instead of SQL Server required adapting SQL syntax, stored procedure development, and ETL execution strategies, providing valuable hands-on experience with database portability.

---

# Future Enhancements

Potential improvements include:

* Automated CSV ingestion using PostgreSQL COPY.
* ETL logging and monitoring.
* Incremental data loading.
* Apache Airflow orchestration.
* Cloud deployment.
* Power BI dashboard integration.
* Data quality monitoring.
* Streaming data ingestion using Apache Kafka.

---

# Conclusion

This project demonstrates an end-to-end Data Warehouse implementation using PostgreSQL, covering data ingestion, transformation, dimensional modeling, and analytical presentation.

Beyond the technical implementation, the project emphasizes software engineering principles such as modularity, documentation, maintainability, and scalability. It provides a solid foundation for extending the warehouse with orchestration, cloud services, and real-time data processing in future iterations.
