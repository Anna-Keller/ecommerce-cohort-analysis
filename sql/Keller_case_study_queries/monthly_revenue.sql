-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.order_items_enriched" with DATASET.ORDERS_ITEMS_ENRICHED_TABLE

SELECT
  DATE_TRUNC(created_at_ts, MONTH) AS month,
  SUM(product_price) AS revenue
FROM products.order_items_enriched
GROUP BY month
ORDER BY month;
