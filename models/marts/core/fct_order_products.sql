{{ 
    config(
    materialized='incremental',
    unique_key = 'surrogate_op_key'
    ) 
    }}

WITH int_order_products AS (
    SELECT *
    FROM {{ ref('int_order_products') }}
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
)

SELECT * FROM int_order_products
