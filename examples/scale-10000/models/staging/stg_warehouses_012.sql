with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        status
,        type
,        created_at
,        capacity
,        region
,        manager_id
    from source
)
select * from renamed
