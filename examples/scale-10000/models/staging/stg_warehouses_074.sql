with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        status
,        created_at
,        location
,        utilization
    from source
)
select * from renamed
