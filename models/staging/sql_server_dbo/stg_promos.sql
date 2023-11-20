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
         , DATE(_fivetran_synced) AS date_load_utc
         , TIME(_fivetran_synced) AS time_load_utc
    FROM src_sql_promos

    UNION ALL

    SELECT    
    'No Promotion' AS promo_name,
    0 AS discount,
    'inactive' AS status,
    '2023-11-11' AS date_load_utc,
    '11:11:35.244000' AS time_load_utc
    ),

stg_promos_final AS (
    SELECT 
          CAST({{ dbt_utils.generate_surrogate_key(['promo_name', 'discount', 'status', 'date_load_utc', 'time_load_utc']) }} AS VARCHAR(300)) AS promo_id
        , CAST(promo_name AS VARCHAR(1050))
        , CAST(discount AS NUMBER(38,0)) AS discount_pct
        , CAST(status AS VARCHAR(500))
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM stg_promos
    )


SELECT * FROM stg_promos_final