with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        capacity
,        utilization
,        region
,        warehouse_name
    from source
)
select * from renamed
