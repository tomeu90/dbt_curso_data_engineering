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
          CAST(address_id AS VARCHAR(300))
        , CAST(address AS VARCHAR(500))
        , CAST(zipcode AS NUMBER(38,0))
        , CAST(country AS VARCHAR(300))
        , CAST(state AS VARCHAR(300))
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_sql_addresses
    )

SELECT * FROM stg_addresses