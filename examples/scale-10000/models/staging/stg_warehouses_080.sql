with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        created_at
,        utilization
,        manager_id
    from source
)
select * from renamed
