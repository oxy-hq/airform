with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        region
,        type
,        created_at
,        manager_id
,        warehouse_name
,        status
,        capacity
    from source
)
select * from renamed
