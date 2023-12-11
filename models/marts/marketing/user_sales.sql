{{
  config(
    materialized='table'
  )
}}

WITH fct_order_products AS (
    SELECT *
    FROM {{ ref('fct_order_products') }}
),

dim_promos AS (
    SELECT *
    FROM {{ ref('dim_promos') }}
),

dim_users AS (
    SELECT *
    FROM {{ ref('dim_users') }}
),

user_sales AS (
    SELECT
        op.user_id AS user_id,
        us.first_name AS first_name,
        us.last_name AS last_name,
        us.address AS address,
        us.zipcode AS zipcode,
        us.country AS country,
        us.state AS state,
        us.phone_number AS phone,
        us.email AS email,
        CAST(COUNT(DISTINCT op.order_id) AS NUMBER(38, 0)) AS order_count,
        CAST(ROUND(SUM(op.total_subcost_usd), 2) AS FLOAT) AS total_expend,
        CAST(ROUND(SUM(op.shipping_subcost_usd), 2) AS FLOAT)
            AS total_shipping_cost,
        CAST(SUM(pr.discount_pct) AS NUMBER(38, 0)) AS total_discount,
        CAST(SUM(op.quantity) AS NUMBER(38, 0)) AS total_products,
        CAST(COUNT(DISTINCT op.product_id) AS NUMBER(38, 0)) AS diff_product
    FROM fct_order_products AS op
    INNER JOIN dim_users AS us
        ON op.user_id = us.user_id
    INNER JOIN dim_promos AS pr
        ON op.promo_id = pr.promo_id
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
)

SELECT * FROM user_sales
