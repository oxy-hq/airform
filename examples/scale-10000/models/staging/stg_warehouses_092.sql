with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        manager_id
,        capacity
,        status
    from source
)
select * from renamed
