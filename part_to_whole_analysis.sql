-- highest contribution categories to sales (percentages)

WITH category_sales AS (
SELECT
    category,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER (),
    CONCAT(ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC