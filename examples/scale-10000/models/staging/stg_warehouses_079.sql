with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        utilization
,        manager_id
,        type
,        status
,        location
,        capacity
    from source
)
select * from renamed
