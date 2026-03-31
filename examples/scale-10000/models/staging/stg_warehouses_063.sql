with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        created_at
,        utilization
,        location
,        capacity
,        manager_id
,        warehouse_name
    from source
)
select * from renamed
