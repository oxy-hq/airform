with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        location
,        created_at
,        warehouse_name
,        status
,        capacity
,        utilization
    from source
)
select * from renamed
