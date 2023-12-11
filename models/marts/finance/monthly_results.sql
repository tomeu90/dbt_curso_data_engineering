{{
  config(
    materialized='table'
  )
}}

WITH budget AS (
    SELECT
        product_id,
        budget_quantity,
        EXTRACT(MONTH FROM month) AS month,
        EXTRACT(YEAR FROM month) AS year
    FROM {{ ref('dim_budget') }}
),

budget_id AS (
    SELECT
        CAST(
            {{ dbt_utils.generate_surrogate_key(['product_id', 'month', 'year']) }} AS VARCHAR(1050)
        )
            AS budget_id,
        *
    FROM budget
),

orders AS (
    SELECT o.created_at_date_utc,
           op.product_id,
           SUM(op.quantity) AS quantity
    FROM {{ ref('fct_order_products') }} AS op
    INNER JOIN {{ ref('dim_orders') }} AS o
    ON op.order_id = o.order_id
    GROUP BY 1, 2
),

month_sales AS (
    SELECT
        d.month AS month,
        d.month_str,
        d.year AS year,
        o.product_id AS product_id,
        SUM(o.quantity) AS monthly_quantity
    FROM orders AS o
    INNER JOIN {{ ref('dim_dates') }} AS d
        ON o.created_at_date_utc = d.date
    GROUP BY 1, 2, 3, 4
),

sales_id AS (
    SELECT
        CAST(
            {{ dbt_utils.generate_surrogate_key(['product_id', 'month', 'year']) }} AS VARCHAR(1050)
        )
            AS budget_id,
        *
    FROM month_sales
),

month_budget AS (
    SELECT s.product_id AS product_id,
           s.month,
           s.month_str,
           s.year,
           s.monthly_quantity,
           b.budget_quantity
    FROM sales_id AS s
    INNER JOIN budget_id AS b
        ON s.budget_id = b.budget_id
    ORDER BY 2
),

products_budget AS (
    SELECT p.name,           
           b.month,
           b.month_str,
           b.year,
           p.inventory,
           b.monthly_quantity,
           b.budget_quantity
    FROM month_budget b
    INNER JOIN {{ ref('dim_products') }} AS p
    ON b.product_id = p.product_id
)

SELECT * FROM products_budget
