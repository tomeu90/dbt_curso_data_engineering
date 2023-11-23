{{
  config(
    materialized='table'
  )
}}

WITH stg_orders AS (
    SELECT * 
    FROM {{ ref('stg_orders') }}
    ),

dim_orders AS (
    SELECT
          order_id
        , created_at_date_utc
        , created_at_time_utc
        , status
        , date_load_utc
        , time_load_utc
    FROM stg_orders 
    ORDER BY order_id
    )

SELECT * FROM dim_orders