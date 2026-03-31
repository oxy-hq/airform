with source as (
    select * from {{ source('raw', 'raw_warehouses') }}
),

renamed as (
    select
        id as warehouse_id
,        status
,        region
,        manager_id
    from source
)

select * from renamed
