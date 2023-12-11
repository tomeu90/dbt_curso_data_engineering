{{
  config(
    materialized='table'
  )
}}

WITH products AS (
    SELECT
        op.product_id AS product_id,
        name,
        price_usd,
        inventory,
        SUM(quantity) AS total_sales,
        ROUND(SUM(order_subcost_usd), 2) AS total_profit
    FROM {{ ref('fct_order_products') }} AS op
    INNER JOIN {{ ref('dim_products') }} AS pr
        ON op.product_id = pr.product_id
    GROUP BY 1, 2, 3, 4
),

promos AS (
    SELECT
        op.product_id AS product_id,
        COUNT(discount_pct) AS discounts_applied,
        ROUND(AVG(discount_pct), 2) AS avg_discount_applied,
        MAX(discount_pct) AS max_discount_applied
    FROM {{ ref('fct_order_products') }} AS op
    INNER JOIN {{ ref('dim_promos') }} AS prm
        ON op.promo_id = prm.promo_id
    WHERE discount_pct != 0
    GROUP BY 1
),

product_sales AS (
    SELECT
        name,
        price_usd,
        inventory,
        CAST(total_sales AS NUMBER(38, 0)) AS total_sales,
        CAST(total_profit AS FLOAT) AS total_profit,
        CAST(discounts_applied AS NUMBER(38, 0)) AS promos_applied,
        CAST(avg_discount_applied AS FLOAT) AS avg_discount_applied,
        CAST(max_discount_applied AS NUMBER(38, 0)) AS max_discount_applied
    FROM products AS prod
    INNER JOIN promos AS pr
        ON prod.product_id = pr.product_id
    ORDER BY 1 ASC
)

SELECT * FROM product_sales
