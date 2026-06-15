# Naming Conventions

This document defines the naming standards for schemas, tables, views, columns, and stored procedures within the data warehouse. Adhering to these conventions ensures consistency, readability, and maintainability across all data layers.

## Table of Contents

* General Principles
* Table Naming Conventions

  * Bronze Layer
  * Silver Layer
  * Gold Layer
* Column Naming Conventions

  * Surrogate Keys
  * Technical Columns
* Stored Procedures

---

# General Principles

* **Naming Convention:** Use `snake_case` with lowercase letters and underscores (`_`) to separate words.
* **Language:** Use English for all object names.
* **Reserved Words:** Avoid using SQL reserved keywords as object names.

---

# Table Naming Conventions

## Bronze Layer

Bronze tables represent raw data ingested from source systems. Table names must preserve the original source table name and be prefixed with the source system.

**Pattern**

```text
<source_system>_<entity>
```

Where:

* **`<source_system>`** – Source system name (e.g., `crm`, `erp`)
* **`<entity>`** – Original table name from the source system

**Example**

```text
crm_customer_info
```

---

## Silver Layer

Silver tables contain cleansed and transformed data. To maintain traceability, table names must follow the same convention as the Bronze layer.

**Pattern**

```text
<source_system>_<entity>
```

Where:

* **`<source_system>`** – Source system name
* **`<entity>`** – Original source table name

**Example**

```text
crm_customer_info
```

---

## Gold Layer

Gold tables are business-ready datasets designed for reporting and analytics. Table names should use business-friendly names and begin with a category prefix.

**Pattern**

```text
<category>_<entity>
```

Where:

* **`<category>`** – Table category (e.g., `dim`, `fact`, `agg`)
* **`<entity>`** – Business entity (e.g., `customers`, `products`, `sales`)

**Examples**

```text
dim_customers
fact_sales
agg_sales_monthly
```

### Category Prefixes

| Prefix  | Description       | Example                              |
| ------- | ----------------- | ------------------------------------ |
| `dim_`  | Dimension tables  | `dim_customer`, `dim_product`        |
| `fact_` | Fact tables       | `fact_sales`                         |
| `agg_`  | Aggregated tables | `agg_customers`, `agg_sales_monthly` |

---

# Column Naming Conventions

## Surrogate Keys

Surrogate keys in dimension tables must use the `_key` suffix.

**Pattern**

```text
<table_name>_key
```

**Example**

```text
customer_key
```

---

## Technical Columns

System-generated metadata columns must begin with the `dwh_` prefix.

**Pattern**

```text
dwh_<column_name>
```

Where:

* **`dwh`** – Reserved prefix for data warehouse metadata
* **`<column_name>`** – Descriptive name of the metadata field

**Example**

```text
dwh_load_date
```

---

# Stored Procedures

Stored procedures responsible for loading data into the warehouse must follow the naming convention below.

**Pattern**

```text
load_<layer>
```

Where:

* **`<layer>`** – Target data layer (`bronze`, `silver`, or `gold`)

**Examples**

```text
load_bronze
load_silver
load_gold
```
