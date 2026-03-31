with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        warehouse_name
,        created_at
,        capacity
,        type
    from source
)
select * from renamed
