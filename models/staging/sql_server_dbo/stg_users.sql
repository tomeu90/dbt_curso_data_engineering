{{
  config(
    materialized='view'
  )
}}

WITH src_sql_users AS (
    SELECT *
    FROM {{ ref('users_snapshot') }}
),

stg_users AS (
    SELECT
        CAST(dbt_scd_id AS VARCHAR(1050)) AS scd_user_id,
        CAST(src_sql_users.user_id AS VARCHAR(1050)) AS user_id,
        CAST(first_name AS VARCHAR(500)) AS first_name,
        CAST(last_name AS VARCHAR(500)) AS last_name,
        CAST(address_id AS VARCHAR(1050)) AS address_id,
        CAST(phone_number AS VARCHAR(50)) AS phone_number,
        CAST(email AS VARCHAR(200)) AS email,
        CAST(DATE(created_at) AS DATE) AS created_at_date_utc,
        CAST(TIME(created_at) AS TIME(9)) AS created_at_time_utc,
        CAST(DATE(updated_at) AS DATE) AS updated_at_date_utc,
        CAST(TIME(updated_at) AS TIME(9)) AS updated_at_time_utc,
        CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc,
        CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc,
        CAST(dbt_valid_from AS TIMESTAMP) AS valid_from_utc,
        CAST(dbt_valid_to AS TIMESTAMP) AS valid_to_utc
    FROM src_sql_users
)

SELECT * FROM stg_users
