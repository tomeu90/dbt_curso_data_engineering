{{
  config(
    materialized='table'
  )
}}

WITH stg_events AS (
    SELECT * 
    FROM {{ ref('stg_events') }}
    ),

fct_session_events AS (
    SELECT
          session_id
        , event_id
        , user_id
        , order_id
        , product_id
        , date_load_utc
        , time_load_utc
    FROM stg_events
    ORDER BY session_id
    )

SELECT * FROM fct_session_events