{{ 
    config(
        materialized='table', 
        sort='date_day',
        dist='date_day',
        pre_hook="alter session set timezone = 'Europe/Madrid'; alter session set week_start = 7;" 
        ) }}

WITH src_dates AS (
    {{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2020-01-01' as date)",
    end_date="cast(GETDATE() as date)"
   )
}}
    ),

stg_dates AS (
    SELECT
          date_day AS date
        , DAY(date_day) AS day
        , EXTRACT(DAYOFWEEK FROM date_day) AS weekday
        , CAST(DECODE(EXTRACT(DAYOFWEEK FROM date_day),
                 0, 'Sunday',
                 1, 'Monday',
                 2, 'Tuesday',
                 3, 'Wednesday',
                 4, 'Thursday',
                 5, 'Friday',
                 'Saturday') AS VARCHAR(20)) AS weekday_str
        , MONTH(date_day) AS month
        , CAST(DECODE(MONTH(date_day),
                 1, 'January',
                 2, 'February',
                 3, 'March',
                 4, 'April',
                 5, 'May',
                 6, 'June',
                 7, 'July',
                 8, 'August',
                 9, 'September',
                 10, 'October',
                 11, 'November',
                 'December') AS VARCHAR(20)) AS month_str
        , YEAR(date_day) AS year
        , WEEK(date_day) AS week
        , EXTRACT(QUARTER FROM date_day) AS quarter
    FROM src_dates
    )

SELECT * FROM stg_dates