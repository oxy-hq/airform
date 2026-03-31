with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        utilization
,        location
,        capacity
,        manager_id
,        created_at
,        warehouse_name
,        type
    from source
)
select * from renamed
