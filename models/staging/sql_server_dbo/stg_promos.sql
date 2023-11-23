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
    SELECT
        CAST(promo_id AS VARCHAR(300)) AS promo_id,
        CAST(discount AS NUMBER(38, 0)) AS discount_pct,
        CAST(status AS VARCHAR(500)) AS status,
        DATE(_fivetran_synced) AS date_load_utc,
        TIME(_fivetran_synced) AS time_load_utc
    FROM src_sql_promos

    UNION ALL

    SELECT
        CAST('No Promotion' AS VARCHAR(300)) AS promo_id,
        CAST(0 AS NUMBER(38, 0)) AS discount_pct,
        CAST('inactive' AS VARCHAR(500)) AS status,
        CURRENT_DATE() AS date_load_utc,
        CURRENT_TIME() AS time_load_utc
),

stg_promos_final AS (
    SELECT
        CAST(
            {{ dbt_utils.generate_surrogate_key(['promo_id']) }} AS VARCHAR(1050)
        )
            AS promo_id,
        CAST(promo_id AS VARCHAR(300)) AS promo_name,
        CAST(discount_pct AS NUMBER(38, 0)) AS discount_pct,
        CAST(status AS VARCHAR(500)) AS status,
        CAST(date_load_utc AS DATE) AS date_load_utc,
        CAST(time_load_utc AS TIME(9)) AS time_load_utc
    FROM stg_promos
)


SELECT * FROM stg_promos_final
