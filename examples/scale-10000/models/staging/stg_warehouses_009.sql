with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        region
,        status
,        type
,        warehouse_name
,        manager_id
    from source
)
select * from renamed
