with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),

renamed as (
    select
        id as shipment_id
,        weight
,        tracking_number
,        order_id
,        delivered_at
,        carrier
,        warehouse_id
    from source
)

select * from renamed
