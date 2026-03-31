with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),

renamed as (
    select
        id as warehouse_id
,        capacity
,        created_at
,        region
,        warehouse_name
,        manager_id
,        status
,        utilization
    from source
)

select * from renamed
