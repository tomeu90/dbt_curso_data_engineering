{{
  config(
    materialized='view'
  )
}}

WITH src_sql_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

stg_shippings AS (
    SELECT
          CAST(tracking_id AS VARCHAR(1050)) AS tracking_id
        , CAST(shipping_service AS VARCHAR(500)) AS shipping_service
        , CAST(address_id AS VARCHAR(1050)) AS address_id
        , CAST(DATE(estimated_delivery_at) AS DATE) AS estimated_delivery_at_date_utc
        , CAST(TIME(estimated_delivery_at) AS TIME(9)) AS estimated_delivery_at_time_utc
        , CAST(DATE(delivered_at) AS DATE) AS delivered_at_date_utc
        , CAST(TIME(delivered_at) AS TIME(9)) AS delivered_at_time_utc
        , CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc
        , CAST(TIME(_fivetran_synced) AS TIME(9)) AS time_load_utc
    FROM src_sql_orders
    WHERE tracking_id != ''
    )

SELECT * FROM stg_shippings