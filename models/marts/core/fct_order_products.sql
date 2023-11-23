{{
  config(
    materialized='table'
  )
}}

WITH stg_order_items AS (
    SELECT * 
    FROM {{ ref('stg_order_items') }}
    ),

stg_orders AS (
    SELECT * 
    FROM {{ ref('stg_orders') }}
    ),

stg_products AS (
    SELECT * 
    FROM {{ ref('stg_products') }}
    ),

fct_order_products AS (
    SELECT
          CAST(a.order_id AS VARCHAR(300)) AS order_id
        , CAST(a.product_id AS VARCHAR(300)) AS product_id
        , CAST(b.user_id AS VARCHAR(300)) AS user_id
        , CAST(b.promo_id AS VARCHAR(300)) AS promo_id
        , CAST(b.tracking_id AS VARCHAR(300)) AS tracking_id
        , CAST(a.quantity AS NUMBER(38,0)) AS quantity
        , CAST(c.price_usd AS NUMBER(38,0)) AS price_usd
        , CAST(a.date_load_utc AS DATE) AS date_load_utc
        , CAST(a.time_load_utc AS TIME(9)) AS time_load_utc
    FROM stg_order_items a
    JOIN stg_orders b
    ON a.order_id = b.order_id
    JOIN stg_products c
    ON a.product_id = c.product_id
    ORDER BY a.order_id
    )

SELECT * FROM fct_order_products