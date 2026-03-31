with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        region
,        capacity
,        created_at
,        utilization
    from source
)
select * from renamed
