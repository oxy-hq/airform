with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        capacity
,        warehouse_name
,        region
    from source
)
select * from renamed
