{{
  config(
    materialized='table'
  )
}}

WITH stg_products AS (
    SELECT * 
    FROM {{ ref('stg_products') }}
    ),

dim_products AS (
    SELECT
          product_id
        , name
        , valid_until
        , valid_flag
        , inventory
        , date_load_utc
        , time_load_utc
    FROM stg_products 
    ORDER BY product_id
    )

SELECT * FROM dim_products