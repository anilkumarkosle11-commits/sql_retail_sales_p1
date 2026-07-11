-- SQL Retail Sales analysis - p1
CREATE DATABASE sql_porject_p1;

-- CREATE TABLE 
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
( 
transactions_id	INT PRIMARY KEY,
sale_date DATE,
sale_time TIME,	
customer_id	INT,
gender VARCHAR(15),	
age VARCHAR(255),	
category VARCHAR(15),	
quantiy VARCHAR(255),	
price_per_unit VARCHAR(255),	
cogs VARCHAR(255),	
total_sale VARCHAR(255)
);

-- Now as i have imprted few data as VARCHAR 255 as few cells having blanks, so now we need to clean the data so that we can change it to int and float

SET SQL_SAFE_UPDATES = 0;

UPDATE retail_sales
SET
age = IF(TRIM(age) = '', NULL, age),
quantiy = IF(TRIM(quantiy) = '', NULL, quantiy),
price_per_unit = IF(TRIM(price_per_unit) = '', NULL, price_per_unit),
cogs = IF(TRIM(cogs) = '', NULL, cogs),
total_sale = IF(TRIM(total_sale) = '', NULL, total_sale);

SET SQL_SAFE_UPDATES = 1;

-- Changing data type as imported file has blank cells in the below column so the data wes being lost, so that it is inserted as Varchar255
ALTER TABLE retail_sales
MODIFY COLUMN age INT,
MODIFY COLUMN quantiy INT,
MODIFY COLUMN price_per_unit INT,
MODIFY COLUMN cogs INT,
MODIFY COLUMN total_sale INT;


-- Viwing NULL values in the table
SELECT * FROM retail_sales
WHERE
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
age IS NULL
OR
category IS NULL
OR
quantiy IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

-- Data Cleaning, Deleting the rows which contains null values as it has no use 
SET SQL_SAFE_UPDATES = 0;
DELETE FROM retail_sales
WHERE
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
age IS NULL
OR
category IS NULL
OR
quantiy IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

SET SQL_SAFE_UPDATES = 0;

-- Data exploration

-- How many sales we have?
SELECT COUNT(*) as total_sales
FROM retail_sales;

-- How Many unique customer we have?
SELECT COUNT(DISTINCT customer_id) as No_of_customer
FROM retail_sales;

-- How Many unique categories we have?
SELECT COUNT(DISTINCT category) as total_category
FROM retail_sales;

-- Unique category in our table
SELECT DISTINCT category as list_of_categories
FROM retail_sales;


-- Data analysis & business key problems and answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022

SELECT *
FROM retail_sales
WHERE category = 'Clothing'
       AND quantiy = '3'
       AND sale_date >='2022-11-01'
       AND sale_date <='2022-11-30';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, SUM(total_sale) as net_sale
FROM retail_sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT category, ROUND(AVG(age),2) as average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM retail_sales
WHERE total_sale >1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT category, gender, COUNT(transactions_id) as total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Q.7 ******Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT 
    year,
    month,
    avg_sale
FROM
(
SELECT 
       YEAR(sale_date) as year, 
	   MONTH(sale_date) as month,
       ROUND(AVG(total_sale),2) as avg_sale,
       RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY ROUND(AVG(total_sale),2) DESC) AS sales_rank
FROM retail_sales
GROUP BY year, month
-- ORDER BY year, avg_sale DESC;
) as t1
WHERE sales_rank = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

# Approach_1
SELECT *
FROM
(
SELECT customer_id,
    SUM(total_sale) as total_sale,
    RANK() OVER(ORDER BY SUM(total_sale) DESC) AS customer_rank
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
) as t1
WHERE customer_rank <=5;

# Approach_2
SELECT customer_id, SUM(total_sale) as total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category, COUNT(DISTINCT customer_id) as unique_id
FROM retail_sales
GROUP BY category;


-- Q.9_modified_ Write a SQL query to find the number of unique customers who purchased items from all category each category.****Modified question

SELECT COUNT(customer_id)
FROM
(SELECT customer_id, COUNT(DISTINCT category) as purchase_category
FROM retail_sales
GROUP BY customer_id) as t1
WHERE purchase_category = 3;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sales
AS
(
SELECT *,
     CASE
        WHEN HOUR(sale_time) <12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END as shift
        
FROM retail_sales
)
SELECT shift, COUNT(*) as total_orders
FROM hourly_sales
GROUP BY shift;

SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*)
FROM retail_sales


-- Sucessfully completion of my first project


