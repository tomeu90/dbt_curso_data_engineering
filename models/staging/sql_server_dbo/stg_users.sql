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
    SELECT u.user_id,
           SUM(CASE WHEN o.order_id IS NOT NULL THEN 1 END) AS order_count
    FROM src_sql_users u
    JOIN src_sql_orders o
    ON u.user_id = o.user_id
    GROUP BY u.user_id
    ),

stg_users AS (
    SELECT
          src_sql_users.user_id AS user_id
        , DATE(created_at) AS created_at_date
        , TIME(created_at) AS created_at_time
        , first_name
        , last_name
        , address_id
        , phone_number
        , email
        , orders_users.order_count AS total_orders
        , DATE(updated_at) AS updated_at_date
        , TIME(updated_at) AS updated_at_time
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_users
    JOIN orders_users
    ON src_sql_users.user_id = orders_users.user_id
    )

SELECT * FROM stg_users