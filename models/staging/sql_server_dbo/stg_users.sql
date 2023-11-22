{{
  config(
    materialized='view'
  )
}}

WITH src_sql_users AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'users') }}
),

src_sql_orders AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'orders') }}
),

orders_users AS (
    SELECT
        u.user_id,
        SUM(CASE WHEN o.order_id IS NOT NULL THEN 1 END) AS order_count
    FROM src_sql_users AS u
    INNER JOIN src_sql_orders AS o
        ON u.user_id = o.user_id
    GROUP BY u.user_id
),

stg_users AS (
    SELECT
        CAST(src_sql_users.user_id AS VARCHAR(1050)) AS user_id,
        CAST(first_name AS VARCHAR(500)) AS first_name,
        CAST(last_name AS VARCHAR(500)) AS last_name,
        CAST(address_id AS VARCHAR(1050)) AS address_id,
        CAST(phone_number AS VARCHAR(50)) AS phone_number,
        CAST(email AS VARCHAR(200)) AS email,
        CAST(orders_users.order_count AS NUMBER(38,0)) AS total_orders,
        CAST(DATE(created_at) AS DATE) AS created_at_date_utc,
        CAST(TIME(created_at) AS TIME(9)) AS created_at_time_utc,
        CAST(DATE(updated_at) AS DATE) AS updated_at_date_utc,
        CAST(TIME(updated_at) AS TIME(9)) AS updated_at_time_utc,
        CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc,
        CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_sql_users
    INNER JOIN orders_users
        ON src_sql_users.user_id = orders_users.user_id
)

SELECT * FROM stg_users
