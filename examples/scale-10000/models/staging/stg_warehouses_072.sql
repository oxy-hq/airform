with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        manager_id
,        warehouse_name
,        utilization
,        region
,        capacity
,        status
    from source
)
select * from renamed
