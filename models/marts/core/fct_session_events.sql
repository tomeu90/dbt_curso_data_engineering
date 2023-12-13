{{ 
    config(
    materialized='incremental',
    unique_key = 'surrogate_se_key'
    ) 
    }}

WITH stg_events AS (
    SELECT *
    FROM {{ ref('stg_events') }}
    {% if is_incremental() %}

        WHERE
            TO_TIMESTAMP(
                date_load_utc || ' ' || time_load_utc, 'YYYY-MM-DD HH24:MI:SS'
            )
            > (
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

int_session_events AS (
    SELECT
        CAST(surrogate_se_key AS VARCHAR(1050)) AS surrogate_se_key,
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