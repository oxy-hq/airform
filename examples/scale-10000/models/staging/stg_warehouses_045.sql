with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        utilization
,        created_at
,        region
,        type
,        location
,        status
,        capacity
    from source
)
select * from renamed
