with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        location
,        capacity
,        manager_id
,        utilization
    from source
)
select * from renamed
