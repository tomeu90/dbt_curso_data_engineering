{{
  config(
    materialized='view'
  )
}}

WITH src_sql_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

stg_orders AS (
    SELECT
          order_id
        , shipping_service
        , shipping_cost
        , address_id
        , created_at
        , promo_id
        , estimated_delivery_at
        , order_cost
        , user_id
        , order_total
        , delivered_at
        , tracking_id
        , status
        , _fivetran_synced AS date_load
    FROM src_sql_orders
    )

SELECT * FROM stg_orders