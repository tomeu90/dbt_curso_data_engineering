{% snapshot products_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='check',
      check_cols=['price'],
        )
}}

select * from {{ source('sql_server_dbo', 'products') }}

{% endsnapshot %}