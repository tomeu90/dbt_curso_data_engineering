{{ 
    config(
    materialized='incremental',
    unique_key = 'surrogate_op_key'
    ) 
    }}

WITH int_order_products AS (
    SELECT *
    FROM {{ ref('int_order_products') }}    
{% if is_incremental() %}

	  where TO_TIMESTAMP(DATE_LOAD_UTC || ' ' || TIME_LOAD_UTC, 'YYYY-MM-DD HH24:MI:SS') > (select max(TO_TIMESTAMP(DATE_LOAD_UTC || ' ' || TIME_LOAD_UTC, 'YYYY-MM-DD HH24:MI:SS')) from {{ this }})

{% endif %}
)

SELECT * FROM int_order_products
