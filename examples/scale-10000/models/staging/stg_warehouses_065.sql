with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        capacity
,        warehouse_name
,        status
,        region
,        location
,        manager_id
    from source
)
select * from renamed
