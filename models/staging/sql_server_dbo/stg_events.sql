{{
  config(
    materialized='view'
  )
}}

WITH src_sql_events AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'events') }}
    ),

stg_events AS (
    SELECT
          event_id
        , page_url
        , event_type
        , user_id
        , product_id
        , session_id
        , created_at
        , order_id
        , _fivetran_synced AS date_load
    FROM src_sql_events
    )

SELECT * FROM stg_events