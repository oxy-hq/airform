with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        manager_id
,        type
,        utilization
,        created_at
,        capacity
,        region
,        location
    from source
)
select * from renamed
