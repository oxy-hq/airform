with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        capacity
,        status
,        utilization
,        location
,        region
    from source
)
select * from renamed
