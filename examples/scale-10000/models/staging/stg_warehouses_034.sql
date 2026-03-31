with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        capacity
,        created_at
,        type
,        region
,        location
,        status
    from source
)
select * from renamed
