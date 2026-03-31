with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        capacity
,        type
,        location
,        status
,        utilization
    from source
)
select * from renamed
