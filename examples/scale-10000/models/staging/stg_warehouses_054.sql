with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        warehouse_name
,        created_at
,        manager_id
,        capacity
,        utilization
,        type
    from source
)
select * from renamed
