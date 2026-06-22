SELECT * FROM gold.dim_customers;

-- Explore all countries from where our customer came from 
SELECT DISTINCT country
FROM gold.dim_customers; 

-- Explore all categories "The major divisions"
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY 1,2,3;