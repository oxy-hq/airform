with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),

renamed as (
    select
        id as warehouse_id
,        capacity
,        manager_id
,        utilization
,        status
    from source
)

select * from renamed
