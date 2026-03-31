with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        warehouse_name
,        utilization
,        location
,        created_at
,        region
,        manager_id
    from source
)
select * from renamed
