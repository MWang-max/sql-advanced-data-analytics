SELECT
*
FROM gold.report_products

SELECT
    subcategory, 
    ROUND(AVG(avg_monthly_revenue), 2) AS avg_monthly_revenue
FROM gold.report_products
GROUP BY subcategory
ORDER BY avg_monthly_revenue DESC

SELECT
    subcategory, 
    SUM(total_customers) AS total_customers
FROM gold.report_products
GROUP BY subcategory
ORDER BY total_customers DESC

SELECT
    subcategory, 
    ROUND(AVG(lifespan), 2) AS avg_lifespan_days
FROM gold.report_products
GROUP BY subcategory
ORDER BY avg_lifespan_days DESC
