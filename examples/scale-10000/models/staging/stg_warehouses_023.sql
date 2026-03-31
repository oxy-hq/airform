with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        location
,        capacity
,        status
,        manager_id
,        region
    from source
)
select * from renamed
