with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),

renamed as (
    select
        id as warehouse_id
,        utilization
,        warehouse_name
,        created_at
,        type
,        status
    from source
)

select * from renamed
