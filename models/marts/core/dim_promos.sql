{{
  config(
    materialized='table'
  )
}}

WITH stg_promos AS (
    SELECT * 
    FROM {{ ref('stg_promos') }}
    ),

dim_promos AS (
    SELECT
          promo_id
        , promo_name
        , discount_pct
        , status
        , date_load_utc
        , time_load_utc
    FROM stg_promos 
    ORDER BY promo_id
    )

SELECT * FROM dim_promos