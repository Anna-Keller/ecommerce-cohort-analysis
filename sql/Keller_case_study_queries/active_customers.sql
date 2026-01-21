-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.order_items_enriched" with DATASET.ORDERS_ITEMS_ENRICHED_TABLE

WITH customer_month_activity AS (
  SELECT
    customer_id,
    DATE_TRUNC(created_at_ts, MONTH) AS month,
    DATE_TRUNC(first_date_order_ts, MONTH) AS first_month
  FROM products.order_items_enriched
)

SELECT
  month,
  CASE
    WHEN month = first_month THEN 'New Customer'
    ELSE 'Returning Customer'
  END AS customer_type,
  COUNT(DISTINCT customer_id) AS customers
FROM customer_month_activity
GROUP BY month, customer_type
ORDER BY month, customer_type;
