SELECT * FROM gold.fact_sales;


-- Find total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- Find how many items are sold.
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- Find Average selling Price 
SELECT ROUND(AVG (price)) FROM gold.fact_sales;

-- Find Total number of orders
SELECT COUNT(DISTINCT order_number) AS total_quantity FROM gold.fact_sales;
-- DISTINCT because a person might order multiple things under the same order number

-- Find total number of products
SELECT COUNT(DISTINCT product_key) AS total_products FROM gold.dim_products;

-- Find total number of customers
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.dim_customers;

-- Total number of customers that have placed an order 
SELECT COUNT(DISTINCT customer_key)
FROM gold.fact_sales
WHERE order_date IS NOT NULL;


-- Generate a Report that Shows all key metrics of the business 
SELECT 'Total Sales' AS measure_name,SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity',SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Avg Selling Price',ROUND(AVG (price)) FROM gold.fact_sales
UNION ALL 
SELECT 'Total Num Orders',COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL 
SELECT 'Total Num Products', COUNT(DISTINCT product_key)FROM gold.dim_products
UNION ALL
SELECT 'Total Num  Customers',COUNT(DISTINCT customer_key) FROM gold.dim_customers;