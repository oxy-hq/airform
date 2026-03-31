with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        status
,        shipped_at
,        delivered_at
,        order_id
,        warehouse_id
,        tracking_number
    from source
)
select * from renamed
