{{
  config(
    materialized='table'
  )
}}

WITH stg_events AS (
    SELECT * 
    FROM {{ ref('stg_events') }}
    ),

dim_events AS (
    SELECT
          event_id
        , page_url
        , event_type
        , created_at_date_utc
        , created_at_time_utc
        , date_load_utc
        , time_load_utc
    FROM stg_events
    ORDER BY event_id
    )

SELECT * FROM dim_events