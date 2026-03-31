with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        manager_id
,        capacity
,        utilization
    from source
)
select * from renamed
