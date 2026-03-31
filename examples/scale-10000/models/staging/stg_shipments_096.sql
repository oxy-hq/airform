with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        warehouse_id
,        shipped_at
,        delivered_at
,        carrier
,        order_id
    from source
)
select * from renamed
