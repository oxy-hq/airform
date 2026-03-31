with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        type
,        created_at
,        capacity
,        region
,        location
,        manager_id
    from source
)
select * from renamed
