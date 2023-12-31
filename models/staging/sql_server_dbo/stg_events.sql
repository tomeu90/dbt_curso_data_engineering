{{ 
    config(
    materialized='incremental',
    unique_key = 'surrogate_se_key'
    ) 
    }}

WITH src_sql_events AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'events') }}
    {% if is_incremental() %}

        WHERE _fivetran_synced > (
            SELECT
                MAX(
                    TO_TIMESTAMP(
                        date_load_utc || ' ' || time_load_utc,
                        'YYYY-MM-DD HH24:MI:SS'
                    )
                )
            FROM {{ this }}
        )

    {% endif %}
    ),

stg_events AS (
    SELECT
          CAST(event_id AS VARCHAR(1050)) AS event_id
        , CAST(page_url AS VARCHAR(1050)) AS page_url
        , CAST(event_type AS VARCHAR(250)) AS event_type
        , CAST(user_id AS VARCHAR(1050)) AS user_id
        , CAST(session_id AS VARCHAR(1050)) AS session_id
        , CAST(DATE(created_at) AS DATE) AS created_at_date_utc
        , CAST(TIME(created_at) AS TIME(9)) AS created_at_time_utc
        , CAST(order_id AS VARCHAR(1050)) AS order_id
        , CAST(product_id AS VARCHAR(1050)) AS product_id
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_sql_events
    )

SELECT     CAST(
        {{ dbt_utils.generate_surrogate_key(['session_id', 'event_id']) }} AS VARCHAR(1050)
    )
        AS surrogate_se_key,
        * FROM stg_events