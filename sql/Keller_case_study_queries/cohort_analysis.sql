-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.order_items_enriched" with DATASET.ORDERS_ITEMS_ENRICHED_TABLE

WITH customer_orders AS (
  SELECT
    customer_id,
    order_number,
    DATE(created_at_ts) AS order_date,
    DATE_TRUNC(DATE(created_at_ts), MONTH) AS order_month
  FROM products.order_items_enriched
  GROUP BY 1,2,3,4
),

customer_cohorts AS (
  SELECT
    customer_id,
    order_number,
    order_month,
    MIN(order_month) OVER (PARTITION BY customer_id) AS cohort_month
  FROM customer_orders
),

cohort_sizes AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size
  FROM customer_cohorts
  GROUP BY cohort_month
),

-- Active customers in each cohort per month
cohort_activity AS (
  SELECT
    cohort_month,
    order_month,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM customer_cohorts
  GROUP BY cohort_month, order_month
)

-- Final table with cohort_retention
SELECT
  a.cohort_month,
  a.order_month,
  DATE_DIFF(a.order_month, a.cohort_month, MONTH) AS months_since_cohort,
  c.cohort_size,
  a.active_customers,
  SAFE_DIVIDE(a.active_customers, c.cohort_size) AS cohort_retention
FROM cohort_activity a
JOIN cohort_sizes c USING (cohort_month)
ORDER BY cohort_month, order_month;
