
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
          _row
        , product_id
        , quantity
        , month
        , _fivetran_synced AS date_load
    FROM src_budget_products
    )

SELECT * FROM stg_budget