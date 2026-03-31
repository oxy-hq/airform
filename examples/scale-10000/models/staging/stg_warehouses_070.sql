with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        utilization
,        manager_id
,        warehouse_name
,        capacity
    from source
)
select * from renamed
