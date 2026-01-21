-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.order_items_enriched" with DATASET.ORDERS_ITEMS_ENRICHED_TABLE

WITH monthly_category_revenue AS (
  SELECT
    DATE_TRUNC(DATE(created_at_ts), MONTH) AS order_month,
    product_category,
    SUM(product_price) AS revenue
  FROM products.order_items_enriched
  GROUP BY order_month, product_category
),

category_totals AS (
  SELECT
    product_category,
    SUM(revenue) AS category_total_revenue,
    AVG(revenue) AS category_avg_monthly_revenue
  FROM monthly_category_revenue
  GROUP BY product_category
),

month_totals AS (
  SELECT
    order_month,
    SUM(revenue) AS month_total_revenue
  FROM monthly_category_revenue
  GROUP BY order_month
)

SELECT
  m.order_month,
  FORMAT_DATE('%Y-%m', m.order_month) AS order_month_label,
  m.product_category,
  m.revenue,

  -- totals
  c.category_total_revenue,
  c.category_avg_monthly_revenue,
  t.month_total_revenue,

  -- % of total (category perspective): how much of a category’s total lands in this month
  SAFE_DIVIDE(m.revenue, c.category_total_revenue) AS pct_of_category_total,

  -- % of total (month perspective): how much of this month’s revenue comes from this category
  SAFE_DIVIDE(m.revenue, t.month_total_revenue) AS pct_of_month_total,

  -- Seasonality index: >1 = above-average month for this category, <1 = below average
  SAFE_DIVIDE(m.revenue, c.category_avg_monthly_revenue) AS seasonality_index

FROM monthly_category_revenue m
JOIN category_totals c USING (product_category)
JOIN month_totals t USING (order_month)
ORDER BY order_month, product_category;
