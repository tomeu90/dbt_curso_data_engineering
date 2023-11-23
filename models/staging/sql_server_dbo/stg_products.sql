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
          CAST(product_id AS VARCHAR(300)) AS product_id
        , CAST(name AS VARCHAR(500)) AS name
        , CAST(price AS FLOAT) AS price_usd
        , CAST(CURRENT_DATE() AS DATE) AS valid_until
        , CAST(CASE WHEN valid_until = CURRENT_DATE() THEN 'Y' ELSE 'N' END AS VARCHAR(5)) AS valid_flag
        , CAST(inventory AS NUMBER(38,0)) AS inventory
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_sql_products
    )

SELECT * FROM stg_products