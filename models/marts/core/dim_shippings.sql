{{
  config(
    materialized='table'
  )
}}

WITH stg_shippings AS (
    SELECT * 
    FROM {{ ref('stg_shippings') }}
    ),

stg_addresses AS (
    SELECT * 
    FROM {{ ref('stg_addresses') }}
    ),

dim_shippings AS (
    SELECT
          CAST(a.tracking_id AS VARCHAR(1050)) AS tracking_id
        , CAST(a.shipping_service AS VARCHAR(500)) AS shipping_service
        , CAST(b.address AS VARCHAR(500)) AS delivery_address
        , CAST(b.zipcode AS NUMBER(38,0)) AS delivery_zipcode
        , CAST(b.country AS VARCHAR(300)) AS delivery_country
        , CAST(b.state AS VARCHAR(300)) AS delivery_state
        , CAST(a.estimated_delivery_at_date_utc AS DATE) AS estimated_delivery_at_date_utc
        , CAST(a.estimated_delivery_at_time_utc AS TIME(9)) AS estimated_delivery_at_time_utc
        , CAST(a.delivered_at_date_utc AS DATE) AS delivered_at_date_utc
        , CAST(a.delivered_at_time_utc AS TIME(9)) AS delivered_at_time_utc
        , CAST(a.date_load_utc AS DATE) AS date_load_utc
        , CAST(a.time_load_utc AS TIME(9)) AS time_load_utc
    FROM stg_shippings a
    JOIN stg_addresses b
    ON a.address_id = b.address_id
    ORDER BY a.tracking_id
    )

SELECT * FROM dim_shippings