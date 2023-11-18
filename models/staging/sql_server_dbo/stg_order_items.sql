{{
  config(
    materialized='view'
  )
}}

WITH src_sql_order_items AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'order_items') }}
    ),

stg_order_items AS (
    SELECT
          order_id
        , product_id
        , quantity
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_order_items
    )

SELECT * FROM stg_order_items