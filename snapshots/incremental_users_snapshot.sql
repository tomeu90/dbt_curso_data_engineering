{% snapshot incremental_users_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='check',
      check_cols=['first_name', 'last_name', 'address_id', 'phone_number'],
      invalidate_hard_deletes=True,     
    )
}}

select * from {{ ref('stg_incremental_users') }}
  where f_carga = (select max(f_carga) from {{ ref('stg_incremental_users') }})


{% endsnapshot %}