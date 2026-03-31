with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        capacity
,        warehouse_name
,        location
    from source
)
select * from renamed
