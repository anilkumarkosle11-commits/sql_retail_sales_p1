# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `sql_porject_p1`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify records with missing or null values and scrub the dataset efficiently.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset's scale.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

---

## Project Structure

### 1. Database Setup & Data Transformation

- **Database & Table Creation**: Setting up the environment and schema. Because the source file contained empty cells, columns were initially imported as `VARCHAR(255)` to ensure zero data loss.
- **Handling Blanks & Type Casting**: Converting empty spaces to `NULL` under `SQL_SAFE_UPDATES = 0` constraints, followed by correcting the structural data types using `ALTER TABLE`.

```sql
CREATE DATABASE sql_porject_p1;

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
( 
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME, 
    customer_id INT,
    gender VARCHAR(15), 
    age VARCHAR(255), 
    category VARCHAR(15), 
    quantiy VARCHAR(255), 
    price_per_unit VARCHAR(255), 
    cogs VARCHAR(255), 
    total_sale VARCHAR(255)
);

-- Handle empty string data cells
SET SQL_SAFE_UPDATES = 0;

UPDATE retail_sales
SET
    age = IF(TRIM(age) = '', NULL, age),
    quantiy = IF(TRIM(quantiy) = '', NULL, quantiy),
    price_per_unit = IF(TRIM(price_per_unit) = '', NULL, price_per_unit),
    cogs = IF(TRIM(cogs) = '', NULL, cogs),
    total_sale = IF(TRIM(total_sale) = '', NULL, total_sale);

SET SQL_SAFE_UPDATES = 1;

-- Alter table to proper numeric datatypes
ALTER TABLE retail_sales
MODIFY COLUMN age INT,
MODIFY COLUMN quantiy INT,
MODIFY COLUMN price_per_unit INT,
MODIFY COLUMN cogs INT,
MODIFY COLUMN total_sale INT;



### 2. Data Exploration & Cleaning
Null Inspection: Querying rows containing missing data points across any critical dimension.
Data Scrubbing: Purging incomplete transaction rows from the table.
High-level Profiling: Calculating baseline counts for unique indicators like customers and product groups.


-- Viewing NULL values in the table
SELECT * FROM retail_sales
WHERE
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR
    customer_id IS NULL OR gender IS NULL OR age IS NULL OR category IS NULL OR
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;


-- Data Cleaning: Deleting unusable records
SET SQL_SAFE_UPDATES = 0;
DELETE FROM retail_sales
WHERE
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR
    customer_id IS NULL OR gender IS NULL OR age IS NULL OR category IS NULL OR
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

-- Baseline Metrics Explorations
SELECT COUNT(*) as total_sales FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) as No_of_customer FROM retail_sales;
SELECT COUNT(DISTINCT category) as total_category FROM retail_sales;
SELECT DISTINCT category as list_of_categories FROM retail_sales;

3. Data Analysis & Business Key Problems
Below are the production SQL analytical queries written to address targeted business questions:

Q.1 Retrieve all columns for sales made on '2022-11-05'

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

Q.2 Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022

SELECT *
FROM retail_sales
WHERE category = 'Clothing'
       AND quantiy = '3'
       AND sale_date >='2022-11-01'
       AND sale_date <='2022-11-30';

Q.3 Calculate the total sales (total_sale) for each category

SELECT category, SUM(total_sale) as net_sale
FROM retail_sales
GROUP BY category;

Q.4 Find the average age of customers who purchased items from the 'Beauty' category

SELECT category, ROUND(AVG(age),2) as average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;

Q.5 Find all transactions where the total_sale is greater than 1000

SELECT *
FROM retail_sales
WHERE total_sale >1000;

Q.6 Find the total number of transactions (transaction_id) made by each gender in each category

SELECT category, gender, COUNT(transactions_id) as total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

Q.7 Calculate the average sale for each month and discover the best-selling month in each year

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
) as t1
WHERE sales_rank = 1;

Q.8 Find the top 5 customers based on the highest total sales
Approach 1 (Window Function):

SELECT *
FROM
(
    SELECT customer_id,
        SUM(total_sale) as total_sale,
        RANK() OVER(ORDER BY SUM(total_sale) DESC) AS customer_rank
    FROM retail_sales
    GROUP BY customer_id
) as t1
WHERE customer_rank <=5;

Approach 2 (Aggregation & Limit):

SELECT customer_id, SUM(total_sale) as total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;

Q.9 Find the number of unique customers who purchased items from each category

SELECT category, COUNT(DISTINCT customer_id) as unique_id
FROM retail_sales
GROUP BY category;

Q.9 (Modified) Find the number of unique customers who purchased items across all categories (3 categories total)

SELECT COUNT(customer_id)
FROM
(
    SELECT customer_id, COUNT(DISTINCT category) as purchase_category
    FROM retail_sales
    GROUP BY customer_id
) as t1
WHERE purchase_category = 3;

Q.10 Segment transactions into explicit time shifts (Morning <=12, Afternoon Between 12 & 17, Evening >17)

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

Findings
Customer Demographics: The target ecosystem includes records with a wide variance in customer age groups, distributed strategically over core categories like Clothing and Beauty.
High-Value Segments: Filtered transactions where total checkout amounts exceed 1000 point to key premium spending clusters.
Sales Trends: Grouping metrics over yearly and monthly periods clearly spotlights peak historical shopping cycles.
Operational Splits: Converting exact timestamp markers using conditional formatting buckets orders into distinct staffing or marketing shifts (Morning, Afternoon, Evening).

Conclusion
This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, handling text-to-numeric type transitions due to messy source formatting, structured data cleaning, exploratory data analysis, and advanced relational queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.


How to Use
Clone the Repository: Clone this project repository to your local directory.
Set Up the Database: Execute the queries provided under the Database Setup portion inside your preferred MySQL interface.
Run the Analysis: Walk through the formatted question scripts to verify data processing rules and performance metrics locally.


Author - Anil Kosle
This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

Stay Updated and Join the Community
LinkedIn: linkedin.com/in/anil-kumar-kosle-78943b200

























