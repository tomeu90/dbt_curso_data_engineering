{{
  config(
    materialized='incremental'
  )
}}

WITH src_sql_users AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'users') }}
{% if is_incremental() %}

	  where _fivetran_synced > (select max(f_carga) from {{ this }})

{% endif %}
),

stg_users AS (
    SELECT
        user_id,
        first_name,
        last_name,
        address_id,
        CAST(REPLACE(phone_number, '-', '') AS NUMBER(38,0)) AS phone_number,
        _fivetran_synced AS f_carga
    FROM src_sql_users
)

SELECT * FROM stg_users
