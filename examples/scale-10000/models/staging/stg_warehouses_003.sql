with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        manager_id
,        region
,        type
,        capacity
,        location
    from source
)
select * from renamed
