with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        created_at
,        utilization
,        type
,        manager_id
,        capacity
    from source
)
select * from renamed
