with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        region
,        warehouse_name
,        status
,        capacity
,        manager_id
    from source
)
select * from renamed
