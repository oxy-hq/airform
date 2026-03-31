with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),

renamed as (
    select
        id as warehouse_id
,        region
,        location
,        created_at
,        utilization
,        status
,        warehouse_name
    from source
)

select * from renamed
