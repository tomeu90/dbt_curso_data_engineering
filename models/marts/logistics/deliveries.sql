{{
  config(
    materialized='table'
  )
}}

WITH orders AS (
    SELECT op.order_id,           
           ROUND(SUM(shipping_subcost_usd), 2) AS shipping_cost,
           shipping_service,
           created_at_date_utc,
           estimated_delivery_at_date_utc,
           delivered_at_date_utc,
           DATEDIFF(DAY, estimated_delivery_at_date_utc, delivered_at_date_utc) AS estimation_diff_days,
           DATEDIFF(DAY, created_at_date_utc, delivered_at_date_utc) AS shipment_duration_days
    FROM {{ ref('fct_order_products') }} op
    INNER JOIN {{ ref('dim_orders') }} o 
    ON op.order_id = o.order_id
    INNER JOIN {{ ref('dim_shippings') }} sh 
    ON op.tracking_id = sh.tracking_id
    WHERE o.status = 'delivered'
    GROUP BY 1, 3, 4, 5, 6, 7, 8
)

SELECT * FROM orders