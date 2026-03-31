with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        capacity
,        region
,        utilization
,        created_at
,        warehouse_name
    from source
)
select * from renamed
