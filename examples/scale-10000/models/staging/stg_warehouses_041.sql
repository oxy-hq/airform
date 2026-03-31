with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        manager_id
,        utilization
,        region
,        capacity
    from source
)
select * from renamed
