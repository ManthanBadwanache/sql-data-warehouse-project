-- Rank Dimension By Measure 

-- Which 5 products generate the highest revenue 
SELECT  dp.product_name,SUM(fs.sales_amount) as total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products As dp 
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Using window functions 
SELECT * FROM 
(
SELECT  dp.product_name,SUM(fs.sales_amount) as total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) as product_rank
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products As dp 
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
)
WHERE product_rank <= 5;

-- Which 5 products generate the lowest revenue 
SELECT  dp.product_name,SUM(fs.sales_amount) as total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products As dp 
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue 
LIMIT 5;

-- Using window functions 
SELECT * FROM 
(
SELECT  dp.product_name,SUM(fs.sales_amount) as total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) ) as product_rank
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products As dp 
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
)
WHERE product_rank <= 5;


-- Find top 10 customers who have generated the highest revenue 
SELECT customer_key, first_name, last_name, total_revenue 
FROM(
SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) as total_revenue,
ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC ) as customer_rank
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
)
WHERE customer_rank <=10;


-- 3 customers with fewest order placed
SELECT * FROM gold.fact_sales;
SELECT customer_key, first_name, last_name, total_orders 
FROM(
SELECT 
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT f.order_number) as total_orders,
ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) ) as customer_rank
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
)
WHERE customer_rank <=3;