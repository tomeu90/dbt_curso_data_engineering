{{ 
    config(
    materialized='incremental',
    unique_key = 'surrogate_se_key'
    ) 
    }}

WITH int_session_events AS (
    SELECT *
    FROM {{ ref('int_session_events') }}    
{% if is_incremental() %}

	  where TO_TIMESTAMP(DATE_LOAD_UTC || ' ' || TIME_LOAD_UTC, 'YYYY-MM-DD HH24:MI:SS') > (select max(TO_TIMESTAMP(DATE_LOAD_UTC || ' ' || TIME_LOAD_UTC, 'YYYY-MM-DD HH24:MI:SS')) from {{ this }})

{% endif %}
)

SELECT * FROM int_session_events
