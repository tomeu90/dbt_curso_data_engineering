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
          {{ dbt_utils.generate_surrogate_key(['promo_id', 'discount', 'status', '_fivetran_synced']) }} AS promo_id
        , promo_id AS promo_name
        , discount
        , status
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_promos
    )

SELECT * FROM stg_promos