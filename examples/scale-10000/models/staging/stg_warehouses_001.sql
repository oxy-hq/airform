with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),
renamed as (
    select
        id as warehouse_id
,        location
,        status
,        created_at
    from source
)
select * from renamed
