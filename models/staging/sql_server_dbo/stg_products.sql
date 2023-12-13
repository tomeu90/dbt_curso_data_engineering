{{ 
    config(
    materialized='incremental',
    unique_key = 'scd_product_id'
    ) 
    }}

WITH src_sql_products AS (
    SELECT *
    FROM {{ ref('products_snapshot') }}
    {% if is_incremental() %}

        WHERE _fivetran_synced > (
            SELECT
                MAX(
                    TO_TIMESTAMP(
                        date_load_utc || ' ' || time_load_utc,
                        'YYYY-MM-DD HH24:MI:SS'
                    )
                )
            FROM {{ this }}
        )

    {% endif %}
),

stg_products AS (
    SELECT
        CAST(dbt_scd_id AS VARCHAR(300)) AS scd_product_id,
        CAST(product_id AS VARCHAR(300)) AS product_id,
        CAST(name AS VARCHAR(500)) AS name,
        CAST(ROUND(price, 2) AS FLOAT) AS price_usd,
        CAST(inventory AS NUMBER(38, 0)) AS inventory,
        CAST(DATE(_fivetran_synced) AS DATE) AS date_load_utc,
        CAST(TIME(_fivetran_synced) AS TIME (9)) AS time_load_utc,
        CAST(dbt_valid_from AS TIMESTAMP) AS valid_from_utc,
        CAST(dbt_valid_to AS TIMESTAMP) AS valid_to_utc
    FROM src_sql_products
)

SELECT * FROM stg_products
