{{
  config(
    materialized='table'
  )
}}

WITH prices AS (
    SELECT scd_product_id,
    name,
    ROUND(price_usd, 2) AS price_usd,
    CASE WHEN valid_to_utc IS NULL THEN CURRENT_DATE() ELSE DATE(valid_to_utc) END AS valid_to_utc
    FROM {{ ref('stg_products') }} p
    ORDER BY 2
)

SELECT * FROM prices