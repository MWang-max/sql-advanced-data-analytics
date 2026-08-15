-- segment products into cost ranges, then count how many are in each segment

WITH product_segments AS (
    SELECT
        product_id, 
        product_name,
        cost,

        CASE WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END cost_range

    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_id) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/*

three segments of customers based on spending behaviour: 
1. VIP - active at least 12 months, more than 5000 spent
2. Regular - active at least 12 months, 5000 or less spent
3. New - active less than 12 months

*/

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) as total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(MAX(f.order_date), MIN(f.order_date)) AS lifespan
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
    ON f.customer_id = c.customer_key
    WHERE c.customer_key IS NOT NULL
    GROUP BY c.customer_key
)
SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers

    FROM (
        SELECT
            customer_key, 

            CASE WHEN lifespan >= 365 AND total_spending > 5000 THEN 'VIP'
                 WHEN lifespan >= 365 AND total_spending <= 5000 THEN 'Regular'
                 ELSE 'New'
            END customer_segment

        FROM customer_spending
    )t 
GROUP BY customer_segment
ORDER BY total_customers DESC
