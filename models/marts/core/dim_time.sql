{{
  config(
    materialized='table'
  )
}}

WITH stg_time AS (
    SELECT * 
    FROM {{ ref('stg_time') }}
    ),

dim_time AS (
    SELECT
          time
        , hour
        , minute
        , second 
    FROM stg_time 
    ORDER BY time
    )

SELECT * FROM dim_time