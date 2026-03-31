with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        warehouse_id
,        delivered_at
    from source
)
select * from renamed
