{{
  config(
    materialized='table'
  )
}}

WITH stg_users AS (
    SELECT * 
    FROM {{ ref('stg_users') }}
    ),

stg_addresses AS (
    SELECT * 
    FROM {{ ref('stg_addresses') }}
    ),

dim_users AS (
    SELECT
          CAST(a.user_id AS VARCHAR(1050)) AS user_id
        , CAST(a.first_name AS VARCHAR(500)) AS first_name
        , CAST(a.last_name AS VARCHAR(500)) AS last_name
        , CAST(b.address AS VARCHAR(500)) AS address
        , CAST(b.zipcode AS NUMBER(38,0)) AS zipcode
        , CAST(b.country AS VARCHAR(300)) AS country
        , CAST(b.state AS VARCHAR(300)) AS state
        , CAST(a.phone_number AS VARCHAR(50)) AS phone_number
        , CAST(a.email AS VARCHAR(200)) AS email
        , CAST(a.created_at_date_utc AS DATE) AS created_at_date_utc
        , CAST(a.created_at_time_utc AS TIME(9)) AS created_at_time_utc
        , CAST(a.updated_at_date_utc AS DATE) AS updated_at_date_utc
        , CAST(a.updated_at_time_utc AS TIME(9)) AS updated_at_time_utc
        , CAST(a.date_load_utc AS DATE) AS date_load_utc
        , CAST(a.time_load_utc AS TIME(9)) AS time_load_utc
    FROM stg_users a
    JOIN stg_addresses b
    ON a.address_id = b.address_id
    ORDER BY a.user_id
    )

SELECT * FROM dim_users