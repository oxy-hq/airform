with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        created_at
,        status
,        region
,        type
,        manager_id
    from source
)
select * from renamed
