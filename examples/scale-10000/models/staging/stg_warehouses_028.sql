with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        utilization
,        type
,        manager_id
,        capacity
    from source
)
select * from renamed
