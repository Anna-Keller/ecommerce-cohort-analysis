-- This script creates a new table with cleaned up, normalized and merged data from both original tables: orders, products
-- to use this script in another environment with different dataset and source table names, search and replace:
-- "products.orders_data" with DATASET.ORDERSTABLE
-- "products.products_data" with DATASET.PRODUCTSTABLE
-- "products.order_items_enriched" with DATASET.order_items_enriched

CREATE OR REPLACE TABLE products.order_items_enriched AS
WITH exact_dedup AS (
  -- Remove exact order duplicates
  SELECT *
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          customer_id,
          created_at,
          order_number,
          product_items,
          total_weight,
          total_discounts,
          processed_at,
          billing_address_country,
          billing_address_zip,
          cancel_reason,
          first_date_order
        ORDER BY created_at
      ) AS rn
    FROM products.orders_data
  )
  WHERE rn = 1
),

-- Normalize country, parse timestamps, split product list
orders_clean AS (
  SELECT
    *,
    CASE
      WHEN billing_address_country LIKE 'C√¥te%' THEN 'Ivory Coast'
      ELSE billing_address_country
    END AS country_clean,
    TIMESTAMP(created_at) AS created_at_ts,
    TIMESTAMP(processed_at) AS processed_at_ts,
    TIMESTAMP(first_date_order) AS first_date_order_ts,
    SPLIT(product_items, ',') AS product_list
  FROM exact_dedup
),


-- Count customers that share each order_number
order_number_stats AS (
  SELECT
    order_number,
    COUNT(DISTINCT customer_id) AS customer_cnt
  FROM orders_clean
  GROUP BY order_number
),

-- Find "same order content" duplicates per customer (without country / zip / cancel here on purpose)
same_order_groups AS (
  SELECT
    o.*,
    COUNT(DISTINCT order_number) OVER (
      PARTITION BY
        customer_id,
        created_at_ts,
        processed_at_ts,
        first_date_order_ts,
        product_items,
        total_weight,
        total_discounts
    ) AS same_order_ordernum_cnt
  FROM orders_clean o
),

  -- Rows to remove: - "same order content" duplicated for this customer AND whose order_number is used by >1 customer
rows_to_remove AS (
  SELECT
    g.customer_id,
    g.order_number,
    g.created_at_ts,
    g.processed_at_ts,
    g.first_date_order_ts,
    g.product_items,
    g.total_weight,
    g.total_discounts
  FROM same_order_groups g
  JOIN order_number_stats s USING (order_number)
  WHERE g.same_order_ordernum_cnt > 1   -- same content twice for this customer
    AND s.customer_cnt > 1              -- order_number shared across customers
),

 -- Keep all orders except the "bad" ones
final_orders AS (
  SELECT
    o.*
  FROM orders_clean o
  LEFT JOIN rows_to_remove r
    ON  o.customer_id         = r.customer_id
    AND o.order_number        = r.order_number
    AND o.created_at_ts       = r.created_at_ts
    AND o.processed_at_ts     = r.processed_at_ts
    AND o.first_date_order_ts = r.first_date_order_ts
    AND o.product_items       = r.product_items
    AND o.total_weight        = r.total_weight
    AND o.total_discounts     = r.total_discounts
  WHERE r.customer_id IS NULL
),

-- Unnest product_items into one row per product
order_items AS (
  SELECT
    o.customer_id,
    o.order_number,
    o.created_at_ts,
    o.processed_at_ts,
    o.first_date_order_ts,
    o.total_weight,
    o.total_discounts,
    o.country_clean,
    o.billing_address_zip,
    o.cancel_reason,
    TRIM(p) AS product_title
  FROM final_orders o
  CROSS JOIN UNNEST(o.product_list) AS p
),

-- Cleanup products
product_dedup AS (
  SELECT
  product_type,
  product_category,
  product_title,
  product_price
FROM (
  SELECT
    product_type,
    product_category,
    product_title,
    product_price,
    ROW_NUMBER() OVER (
      PARTITION BY product_title
      ORDER BY product_type, product_category
    ) AS rn
  FROM products.products_data
  )
WHERE rn = 1
),

-- Join orders with product data 
order_items_enriched AS (
  SELECT
    oi.*,
    pr.product_category,
    pr.product_type,
    pr.product_price
  FROM order_items oi
  LEFT JOIN product_dedup pr
    ON oi.product_title = pr.product_title
)

-- Select everything to save to a new table
SELECT *
FROM order_items_enriched ORDER BY created_at_ts DESC;