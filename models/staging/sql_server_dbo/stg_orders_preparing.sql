{{
  config(
    materialized='view'
  )
}}

WITH src_sql_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

stg_orders_prep AS (
    SELECT
          order_id
        , DATE(created_at) AS created_at_date
        , TIME(created_at) AS created_at_time
        , DECODE(promo_id,
                 'task-force', '90f31b8933d4fd0aeeac91e95d7a8789',
                 'instruction set', '075af70146fca96dfdcc121a1038eb6d',
                 'leverage', '31eb2663e65cb8bc82b377455816ed7c',
                 'Optional', '170c5ec460854a056b9193ffe5f7dfcd',
                 'Mandatory', '2a90602f47250840445dd35f7047db1c',
                 'Digitized', '9f590bee523309da4adad7e951530814',
                 '93a1e6c0b1c5ccb5d38c3627eda162b1'
                ) AS promo_id
        , order_cost
        , shipping_cost
        , order_total
        , user_id
        , status
        , CASE WHEN tracking_id = '' THEN 'Pending shipment' ELSE tracking_id END AS tracking_id
        , DATE(_fivetran_synced) AS date_load
        , TIME(_fivetran_synced) AS time_load
    FROM src_sql_orders
    )

SELECT * FROM stg_orders_prep