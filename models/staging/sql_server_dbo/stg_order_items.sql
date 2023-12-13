{{ 
    config(
    materialized='incremental',
    unique_key = 'surrogate_op_key'
    ) 
    }}

WITH src_sql_order_items AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'order_items') }}
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

stg_order_items AS (
    SELECT
        CAST(order_id AS VARCHAR(300)) AS order_id,
        CAST(product_id AS VARCHAR(300)) AS product_id,
        CAST(quantity AS NUMBER(38, 0)) AS quantity,
        CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc,
        CAST(TIME(_fivetran_synced) AS TIME (9)) AS time_load_utc
    FROM src_sql_order_items
)

SELECT
    CAST(
        {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} AS VARCHAR(1050)
    )
        AS surrogate_op_key,
    *
FROM stg_order_items
