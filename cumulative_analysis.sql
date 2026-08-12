-- total sales per month, cumulative total up to each month

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM(
SELECT
    MONTH(order_date) AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
)t

-- running total by year

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM(
SELECT
    YEAR(order_date) AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
)t

-- moving average by month 

SELECT
    order_date,
    total_sales,
    ROUND(AVG(avg_price) OVER (ORDER BY order_date), 2) AS moving_avg_price
FROM(
SELECT
    MONTH(order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
)t

-- moving average by year

SELECT
    order_date,
    total_sales,
    ROUND(AVG(avg_price) OVER (ORDER BY order_date), 2) AS moving_avg_price
FROM(
SELECT
    YEAR(order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
)t