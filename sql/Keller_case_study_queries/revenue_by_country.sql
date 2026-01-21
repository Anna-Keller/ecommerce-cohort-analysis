-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.order_items_enriched" with DATASET.ORDERS_ITEMS_ENRICHED_TABLE

SELECT
  country_clean AS country,
  SUM(product_price) AS revenue,
  SAFE_DIVIDE(
    SUM(product_price),
    SUM(SUM(product_price)) OVER ()
  ) AS pct_of_total_revenue
FROM products.order_items_enriched
GROUP BY country
ORDER BY revenue DESC;
