with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        utilization
,        manager_id
,        warehouse_name
,        region
,        status
,        type
,        created_at
    from source
)
select * from renamed
