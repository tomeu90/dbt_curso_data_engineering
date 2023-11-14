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
          promo_id
        , discount
        , status
        , _fivetran_synced AS date_load
    FROM src_sql_promos
    )

SELECT * FROM stg_promos