{{
  config(
    materialized='table'
  )
}}

WITH stg_dates AS (
    SELECT * 
    FROM {{ ref('stg_dates') }}
    ),

dim_dates AS (
    SELECT
          date
        , day
        , weekday
        , weekday_str
        , month
        , month_str
        , year
        , week
        , quarter
    FROM stg_dates 
    ORDER BY date
    )

SELECT * FROM dim_dates