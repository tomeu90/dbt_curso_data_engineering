{{
  config(
    materialized='view'
  )
}}

WITH src_sql_promos AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'promos') }}
    ),

stg_promos AS (
    SELECT promo_id AS promo_name
         , discount
         , status
         , DATE(_fivetran_synced) AS date_load
         , TIME(_fivetran_synced) AS time_load
    FROM src_sql_promos

    UNION ALL

    SELECT    
    'No Promotion' AS PROMO_NAME,
    0 AS DISCOUNT,
    'inactive' AS STATUS,
    '2023-11-11' AS DATE_LOAD,
    '11:11:35.244000' AS TIME_LOAD
    ),

stg_promos_final AS (
    SELECT {{ dbt_utils.generate_surrogate_key(['promo_name', 'discount', 'status', 'date_load', 'time_load']) }} AS promo_id
         , promo_name
         , discount AS discount_pct
         , status
         , date_load
         , time_load
    FROM stg_promos
    )


SELECT * FROM stg_promos_final