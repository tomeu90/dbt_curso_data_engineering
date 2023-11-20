{{
  config(
    materialized='view'
  )
}}

WITH src_sql_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

stg_shippings AS (
    SELECT
          tracking_id
        , shipping_service
        , address_id
        , DATE(estimated_delivery_at) AS estimated_delivery_at_date_utc
        , TIME(estimated_delivery_at) AS estimated_delivery_at_time_utc
        , DATE(delivered_at) AS delivered_at_date_utc
        , TIME(delivered_at) AS delivered_at_time_utc
        , DATE(_fivetran_synced) AS date_load_utc
        , TIME(_fivetran_synced) AS time_load_utc
    FROM src_sql_orders
    WHERE tracking_id != ''
    )

SELECT * FROM stg_shippings