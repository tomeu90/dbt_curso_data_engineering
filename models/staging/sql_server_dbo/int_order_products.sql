{{ 
    config(
    materialized='view'
    ) 
    }}

WITH stg_order_items AS (
    SELECT *
    FROM {{ ref('stg_order_items') }}
),

stg_orders AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),

agg_orders AS (
    SELECT
        a.order_id,
        SUM(b.quantity) AS total_quantity
    FROM {{ ref('stg_orders') }} AS a
    INNER JOIN {{ ref('stg_order_items') }} AS b
        ON a.order_id = b.order_id
    GROUP BY 1
),

stg_products AS (
    SELECT *
    FROM {{ ref('stg_products') }}
    WHERE valid_to_utc IS NULL
),

fct_order_products AS (
    SELECT
        CAST(
            {{ dbt_utils.generate_surrogate_key(['a.order_id', 'a.product_id']) }} AS VARCHAR(1050)
        )
            AS surrogate_op_key,
        CAST(a.order_id AS VARCHAR(300)) AS order_id,
        CAST(a.product_id AS VARCHAR(300)) AS product_id,
        CAST(b.user_id AS VARCHAR(300)) AS user_id,
        CAST(b.promo_id AS VARCHAR(300)) AS promo_id,
        CAST(b.tracking_id AS VARCHAR(300)) AS tracking_id,
        CAST(a.quantity AS NUMBER(38, 0)) AS quantity,
        CAST(c.price_usd AS FLOAT) AS price_usd,
        CAST(ROUND(a.quantity * c.price_usd, 2) AS FLOAT) AS order_subcost_usd,
        CAST(
            ROUND(
                b.shipping_cost_usd * (a.quantity / d.total_quantity), 2
            ) AS FLOAT
        ) AS shipping_subcost_usd,
        CAST(ROUND(order_subcost_usd + shipping_subcost_usd, 2) AS FLOAT)
            AS total_subcost_usd,
        CAST(a.date_load_utc AS DATE) AS date_load_utc,
        CAST(a.time_load_utc AS TIME (9)) AS time_load_utc
    FROM stg_order_items AS a
    INNER JOIN stg_orders AS b
        ON a.order_id = b.order_id
    INNER JOIN stg_products AS c
        ON a.product_id = c.product_id
    INNER JOIN agg_orders AS d
        ON a.order_id = d.order_id
    ORDER BY 1
)

SELECT * FROM fct_order_products