with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        utilization
,        warehouse_name
,        capacity
,        manager_id
    from source
)
select * from renamed
