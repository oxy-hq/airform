with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        utilization
,        type
,        capacity
,        status
,        manager_id
,        created_at
    from source
)
select * from renamed
