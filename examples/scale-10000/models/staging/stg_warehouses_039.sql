with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        region
,        status
,        manager_id
,        warehouse_name
,        created_at
,        capacity
    from source
)
select * from renamed
