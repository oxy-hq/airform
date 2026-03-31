with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        type
,        region
,        utilization
,        created_at
,        capacity
,        location
    from source
)
select * from renamed
