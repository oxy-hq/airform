with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        type
,        location
,        region
,        status
,        utilization
,        created_at
    from source
)
select * from renamed
