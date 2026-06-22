# Exploratory Data Analysis (EDA)

## Overview

This folder contains SQL scripts used to perform **Exploratory Data Analysis (EDA)** on the Gold layer of the PostgreSQL Data Warehouse.

The objective of these scripts is to understand the structure, quality, distribution, and business characteristics of the data before performing advanced analytical tasks.

Unlike the ETL process, these scripts **do not modify data**. They are intended solely for exploration, validation, and business insight generation.

---

# Objectives

The exploratory analysis focuses on answering questions such as:

* What dimensions are available for analysis?
* What is the time span covered by the data?
* What are the overall business metrics?
* How are customers and products distributed?
* Which products and customers contribute most to revenue?

---

# Folder Structure

```text
eda/
│
├── 01_dimension_exploration.sql
├── 02_date_exploration.sql
├── 03_measure_exploration.sql
├── 04_magnitude_analysis.sql
└── 05_ranking_analysis.sql
```

---

# Script Description

## 01_dimension_exploration.sql

Explores descriptive attributes available in the warehouse.

Key analyses include:

* Customer countries
* Product categories
* Product subcategories

---

## 02_date_exploration.sql

Explores temporal characteristics of the warehouse.

Key analyses include:

* First and last sales order
* Data coverage period
* Youngest customer
* Oldest customer

---

## 03_measure_exploration.sql

Calculates key business metrics.

Metrics include:

* Total Sales
* Total Quantity Sold
* Average Selling Price
* Total Orders
* Total Products
* Total Customers

---

## 04_magnitude_analysis.sql

Analyzes business measures across dimensions.

Examples include:

* Customers by Country
* Customers by Gender
* Products by Category
* Average Product Cost
* Revenue by Category
* Revenue by Customer
* Sales Distribution by Country

---

## 05_ranking_analysis.sql

Ranks business entities using SQL window functions.

Examples include:

* Top Revenue-Generating Products
* Lowest Revenue Products
* Highest Revenue Customers
* Customers with the Fewest Orders

---

# Dataset

All analyses are performed using the **Gold Layer**.

Objects used include:

* `gold.dim_customers`
* `gold.dim_products`
* `gold.fact_sales`

---

# Purpose

The analyses in this folder help validate the data warehouse while providing an understanding of business trends before performing advanced analytics and reporting.
