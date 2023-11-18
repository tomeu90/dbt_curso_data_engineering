{{
  config(
    materialized='view'
  )
}}

WITH src_sql_events AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'events') }}
    ),

stg_events_customers AS (
    SELECT
          event_id
        , page_url
        , event_type
        , user_id
        , session_id
        , created_at
        , order_id
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_events
    WHERE order_id != ''
    )

SELECT * FROM stg_events_customers