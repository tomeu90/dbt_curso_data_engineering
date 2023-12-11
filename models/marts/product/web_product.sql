{{
  config(
    materialized='table'
  )
}}

WITH fct_session_events AS (
    SELECT *
    FROM {{ ref('fct_session_events') }}
),

dim_events AS (
    SELECT *
    FROM {{ ref('dim_events') }}
),

dim_users AS (
    SELECT *
    FROM {{ ref('dim_users') }}
),

table_prod AS (
    SELECT
        se.session_id AS session_id,
        us.user_id AS user_id,
        se.event_id AS event_id,
        ev.event_type AS event_type,
        ev.page_url AS page_url,
        us.address AS address,
        us.zipcode AS zipcode,
        us.country AS country,
        us.state AS state,
        us.phone_number AS phone,
        us.email AS email,
        CONCAT(us.first_name, ' ', us.last_name) AS name,
        CONCAT(ev.created_at_date_utc, ' ', ev.created_at_time_utc)
            AS created_at
    FROM fct_session_events AS se
    INNER JOIN dim_events AS ev
        ON se.event_id = ev.event_id
    INNER JOIN dim_users AS us
        ON se.user_id = us.user_id
),

web_product_table AS (
    SELECT
        session_id,
        user_id,
        name AS full_name,
        address,
        zipcode,
        country,
        state,
        phone,
        email,
        CAST(MIN(created_at) AS DATETIME) AS session_start,
        CAST(MAX(created_at) AS DATETIME) AS session_end,
        CAST(TIMEDIFF(MINUTE, session_start, session_end) AS NUMBER(38, 0))
            AS session_time_minutes,
        CAST(COUNT(DISTINCT page_url) AS NUMBER(38, 0)) AS page_visits,
        CAST(
            SUM(
                CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END
            ) AS NUMBER(38, 0)
        ) AS add_to_cart,
        CAST(
            SUM(CASE WHEN event_type = 'checkout' THEN 1 ELSE 0 END) AS NUMBER(
                38, 0
            )
        ) AS checkout,
        CAST(
            SUM(
                CASE WHEN event_type = 'package_shipped' THEN 1 ELSE 0 END
            ) AS NUMBER(38, 0)
        ) AS package_shipped
    FROM table_prod
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
)

SELECT * FROM web_product_table
