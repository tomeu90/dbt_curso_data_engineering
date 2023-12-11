{{
  config(
    materialized='table'
  )
}}

WITH stg_products AS (
    SELECT * 
    FROM {{ ref('stg_products') }}
    WHERE valid_to_utc IS NULL    
    ),

dim_products AS (
    SELECT
          product_id
        , name
        , inventory
        , date_load_utc
        , time_load_utc
    FROM stg_products 
    ORDER BY product_id
    )

SELECT * FROM dim_products