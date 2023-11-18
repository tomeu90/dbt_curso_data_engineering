{{
  config(
    materialized='view'
  )
}}

WITH src_sql_products AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'products') }}
    ),

stg_products AS (
    SELECT
          product_id
        , name
        , price AS price_usd
        , inventory
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_products
    )

SELECT * FROM stg_products