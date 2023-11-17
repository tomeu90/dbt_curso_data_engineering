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
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_addresses
    )

SELECT * FROM stg_addresses