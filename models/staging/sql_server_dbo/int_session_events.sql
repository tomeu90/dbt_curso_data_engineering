{{
  config(
    materialized='view'
  )
}}

WITH stg_events AS (
    SELECT *
    FROM {{ ref('stg_events') }}
),

int_session_events AS (
    SELECT
        CAST(
            {{ dbt_utils.generate_surrogate_key(['session_id', 'event_id']) }} AS VARCHAR(1050)
        )
            AS surrogate_se_key,
        session_id,
        event_id,
        user_id,
        order_id,
        product_id,
        date_load_utc,
        time_load_utc
    FROM stg_events
    ORDER BY session_id
)

SELECT * FROM int_session_events