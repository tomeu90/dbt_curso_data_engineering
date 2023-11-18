
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
          product_id
        , quantity
        , month
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_budget_products
    )

SELECT * FROM stg_budget