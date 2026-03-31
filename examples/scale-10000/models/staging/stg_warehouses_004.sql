with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        manager_id
,        created_at
,        type
,        region
,        warehouse_name
,        utilization
    from source
)
select * from renamed
