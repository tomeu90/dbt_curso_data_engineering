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
          CAST(order_id AS VARCHAR(300))
        , CAST(product_id AS VARCHAR(300))
        , CAST(quantity AS NUMBER(38,0))
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_sql_order_items
    )

SELECT * FROM stg_order_items