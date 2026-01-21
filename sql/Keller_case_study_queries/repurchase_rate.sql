-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.order_items_enriched" with DATASET.ORDERS_ITEMS_ENRICHED_TABLE

WITH customer_orders AS (
  SELECT
    customer_id,
    order_number,
    DATE_TRUNC(DATE(created_at_ts), MONTH) AS order_month
  FROM products.order_items_enriched
  GROUP BY 1,2,3
),

-- Assign to a cohort
customer_cohorts AS (
  SELECT
    customer_id,
    MIN(order_month) AS cohort_month
  FROM customer_orders
  GROUP BY customer_id
),

-- Rank orders per customer (to see who repurchased)
orders_with_rank AS (
  SELECT
    o.customer_id,
    o.order_number,
    o.order_month,
    c.cohort_month,
    ROW_NUMBER() OVER (
      PARTITION BY o.customer_id
      ORDER BY o.order_month, o.order_number
    ) AS order_rank
  FROM customer_orders o
  JOIN customer_cohorts c USING (customer_id)
),

-- Aggregate per cohort
cohort_repurchase AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN order_rank > 1 THEN customer_id END)
      AS customers_with_repurchase
  FROM orders_with_rank
  GROUP BY cohort_month
)

SELECT
  cohort_month,
  cohort_size,
  customers_with_repurchase,
  SAFE_DIVIDE(customers_with_repurchase, cohort_size) AS repurchase_rate
FROM cohort_repurchase
ORDER BY cohort_month;
