{{
  config(
    materialized='table'
  )
}}

WITH sales AS (
    SELECT
        o.created_at_date_utc,
        COUNT(DISTINCT op.order_id) AS order_count,
        SUM(op.quantity) AS quantity,
        SUM(op.order_subcost_usd) AS order_cost_usd,
        ROUND(SUM(op.shipping_subcost_usd), 2) AS shipping_cost_usd,
        ROUND(SUM(op.total_subcost_usd), 2) AS total_cost_usd
    FROM {{ ref('fct_order_products') }} op
    INNER JOIN {{ ref('dim_orders') }} o
        ON op.order_id = o.order_id
    GROUP BY 1
    ORDER BY 1
),

date_sales AS (
    SELECT
        s.created_at_date_utc,
        s.order_count,
        s.quantity,
        s.order_cost_usd,
        s.shipping_cost_usd,
        s.total_cost_usd,
        d.day,
        d.weekday_str,
        d.month,
        d.month_str,
        d.year,
        d.week,
        d.quarter
    FROM sales AS s
    INNER JOIN {{ ref('dim_dates') }} AS d
        ON s.created_at_date_utc = d.date
)

SELECT * FROM date_sales
