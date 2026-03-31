with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        created_at
,        manager_id
,        type
,        warehouse_name
    from source
)
select * from renamed
