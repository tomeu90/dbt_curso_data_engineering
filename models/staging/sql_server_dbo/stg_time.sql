{{ 
    config(
        materialized='table', 
        sort='time',
        dist='time',
        pre_hook="alter session set timezone = 'Europe/Madrid'; alter session set week_start = 7;" 
        ) }}

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
          CAST(TIME(date_second) AS TIME(9)) AS time
        , HOUR(date_second) AS hour
        , MINUTE(date_second) AS minute
        , SECOND(date_second) AS second        
    FROM src_time
    )

SELECT * FROM stg_time