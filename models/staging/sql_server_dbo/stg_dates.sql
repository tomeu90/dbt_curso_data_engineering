{{
  config(
    materialized='view'
  )
}}

WITH src_dates AS (
    {{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2020-01-01' as date)",
    end_date="cast('2023-12-01' as date)"
   )
}}
    ),

stg_dates AS (
    SELECT
          date_day AS date
        , DAY(date_day) AS day
        , EXTRACT(DAYOFWEEK FROM date_day) AS weekday
        , DECODE(EXTRACT(DAYOFWEEK FROM date_day),
                 0, 'Sunday',
                 1, 'Monday',
                 2, 'Tuesday',
                 3, 'Wednesday',
                 4, 'Thursday',
                 5, 'Friday',
                 'Saturday') AS weekday_str
        , MONTH(date_day) AS month
        , DECODE(MONTH(date_day),
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
                 'December') AS month_str
        , YEAR(date_day) AS year
        , WEEK(date_day) AS week
        , EXTRACT(QUARTER FROM date_day) AS quarter
    FROM src_dates
    )

SELECT * FROM stg_dates