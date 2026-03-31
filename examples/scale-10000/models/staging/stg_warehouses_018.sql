with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        utilization
,        region
,        status
,        capacity
    from source
)
select * from renamed
