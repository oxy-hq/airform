with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        region
,        created_at
,        capacity
,        warehouse_name
,        location
    from source
)
select * from renamed
