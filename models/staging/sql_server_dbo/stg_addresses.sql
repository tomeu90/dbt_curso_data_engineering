{{
  config(
    materialized='view'
  )
}}

WITH src_sql_addresses AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'addresses') }}
    ),

stg_addresses AS (
    SELECT
          address_id
        , zipcode
        , country
        , address
        , state
        , _fivetran_synced AS date_load
    FROM src_sql_addresses
    )

SELECT * FROM stg_addresses