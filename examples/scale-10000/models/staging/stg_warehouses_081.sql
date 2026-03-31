with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        manager_id
,        created_at
,        capacity
,        warehouse_name
,        location
,        type
    from source
)
select * from renamed
