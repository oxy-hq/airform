with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        capacity
,        type
,        warehouse_name
,        manager_id
,        location
    from source
)
select * from renamed
