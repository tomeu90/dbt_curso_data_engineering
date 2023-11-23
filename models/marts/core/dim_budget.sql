{{
  config(
    materialized='table'
  )
}}

WITH stg_budget AS (
    SELECT * 
    FROM {{ ref('stg_google_sheets_budget') }}
    ),

dim_budget AS (
    SELECT
          product_id
        , quantity AS budget_quantity
        , month
        , date_load_utc
        , time_load_utc
    FROM stg_budget 
    ORDER BY product_id
    )

SELECT * FROM dim_budget