
{{
  config(
    materialized='view'
  )
}}

WITH src_budget_products AS (
    SELECT * 
    FROM {{ source('google_sheets', 'budget') }}
    ),

stg_budget AS (
    SELECT
          CAST(product_id AS VARCHAR(300))
        , CAST(quantity AS NUMBER(38,0))
        , CAST(month AS DATE)
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_budget_products
    )

SELECT * FROM stg_budget