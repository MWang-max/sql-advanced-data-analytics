/*

Customer report: 

- name, age, transaction details
- VIP, regular, new customer categories
- age groups for customers
- total orders
- total sales
- quantity purchased
- total products
- lifespan 

KPIs: 
- recency of last order
- average order value
- average monthly spending

*/
CREATE VIEW gold.report_customers AS (
WITH base_query AS (
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    TIMESTAMPDIFF(YEAR, c.birthdate, now()) AS age
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_id
WHERE order_date IS NOT NULL AND first_name IS NOT NULL AND last_name IS NOT NULL
), customer_aggregation AS(
SELECT -- aggregations: - total orders, total sales, quantity purchased, total products, lifespan 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS lifespan
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)
SELECT -- segmentation into VIP, regular, new; age groups
    customer_key,
    customer_number,
    customer_name,

    CASE WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,

    CASE WHEN lifespan >= 365 AND total_sales > 5000 THEN 'VIP'
         WHEN lifespan >= 365 AND total_sales <= 5000 THEN 'Regular'
         ELSE 'New'
    END customer_segment, 

    last_order,
    TIMESTAMPDIFF(MONTH, last_order, now()) AS recency,

    total_orders,
    total_sales,
    total_quantity,
    total_products, 
    lifespan,

    CASE WHEN total_orders = 0 THEN 0 -- average order value (avoid divide by 0)
         ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_value, 

    CASE WHEN lifespan = 0 THEN total_sales -- average monthly spending 
         ELSE ROUND(total_sales/lifespan, 2)
    END AS avg_monthly_spend

FROM customer_aggregation
)

-- quality check
SELECT 
*
FROM gold.report_customers

SELECT 
    customer_segment,
    SUM(total_sales) AS total_sales
FROM gold.report_customers
GROUP BY customer_segment
ORDER BY customer_segment DESC