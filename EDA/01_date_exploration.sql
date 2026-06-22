-- Identify the Earliest and the latest dates in our dara (boundaries)
-- Understand the scope of data and timespan

-- Find the date of first and last order
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    (
        EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
        + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
    ) AS months_diff
FROM gold.fact_sales;

--Find the youngest and the oldest customers 
SELECT MIN(birthdate) AS oldest_birthdate,
	   MAX(birthdate) AS latest_birthdate,
	   EXTRACT( YEAR FROM (AGE(NOW(),MAX(birthdate)))) AS youngest_age,
	   EXTRACT( YEAR FROM (AGE(NOW(),MIN(birthdate)))) AS oldest_age
FROM gold.dim_customers ;

-- For months
SELECT MIN(birthdate) AS oldest_birthdate,
	   MAX(birthdate) AS latest_birthdate,
	   EXTRACT( YEAR FROM (AGE(NOW(),MAX(birthdate))))*12 + EXTRACT(MONTH FROM(AGE(NOW(),MAX(birthdate)))) AS youngest_age_in_months,
	   EXTRACT( YEAR FROM (AGE(NOW(),MIN(birthdate))))*12 + EXTRACT(MONTH FROM(AGE(NOW(),MIN(birthdate)))) AS oldest_age_in_months
FROM gold.dim_customers;