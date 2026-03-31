with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        created_at
,        region
,        utilization
    from source
)
select * from renamed
