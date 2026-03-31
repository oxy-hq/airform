with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        region
,        utilization
,        capacity
,        location
,        type
,        status
,        manager_id
    from source
)
select * from renamed
