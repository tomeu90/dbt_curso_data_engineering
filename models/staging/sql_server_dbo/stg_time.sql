{{
  config(
    materialized='view'
  )
}}

WITH src_time AS (
    {{ dbt_utils.date_spine(
    datepart="second",
    start_date="cast('2020-01-01' as date)",
    end_date="cast('2020-01-02' as date)"
   )
}}
    ),

stg_time AS (
    SELECT    
    NULL AS time,
    NULL AS hour,
    NULL AS minute,
    NULL AS second

    UNION ALL

    SELECT
          TIME(date_second) AS time
        , HOUR(date_second) AS hour
        , MINUTE(date_second) AS minute
        , SECOND(date_second) AS second        
    FROM src_time
    )

SELECT * FROM stg_time