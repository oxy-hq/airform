with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        status
,        created_at
,        region
,        capacity
,        warehouse_name
    from source
)
select * from renamed
