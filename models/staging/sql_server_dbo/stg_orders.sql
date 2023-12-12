{{ 
    config(
    materialized='incremental',
    unique_key = 'order_id'
    ) 
    }}

WITH src_sql_orders AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'orders') }}
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

fixed_promo AS (
    SELECT
        order_id,
        shipping_service,
        shipping_cost,
        address_id,
        created_at,
        estimated_delivery_at,
        order_cost,
        user_id,
        order_total,
        delivered_at,
        tracking_id,
        status,
        _fivetran_synced,
        CASE WHEN promo_id = '' THEN 'No Promotion' ELSE promo_id END
            AS promo_id
    FROM src_sql_orders
),

stg_orders AS (
    SELECT
        CAST(order_id AS VARCHAR(1050)) AS order_id,
        CAST(DATE(created_at) AS DATE) AS created_at_date_utc,
        CAST(TIME(created_at) AS TIME (9)) AS created_at_time_utc
        , {{ dbt_utils.generate_surrogate_key(['promo_id']) }} AS promo_id
        , CAST(order_cost AS FLOAT) AS order_cost_usd
        , CAST(shipping_cost AS FLOAT) AS shipping_cost_usd
        , CAST(order_total AS FLOAT) AS order_total_usd
        , CAST(user_id AS VARCHAR(1050)) AS user_id
        , CAST(status AS VARCHAR(500)) AS status
        , CAST(tracking_id AS VARCHAR(1050)) AS tracking_id
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM fixed_promo
)

SELECT * FROM stg_orders
