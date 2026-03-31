with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        created_at
,        type
,        capacity
,        utilization
,        location
    from source
)
select * from renamed
