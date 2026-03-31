with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        warehouse_id
,        weight
,        cost
,        carrier
,        order_id
,        delivered_at
,        tracking_number
    from source
)
select * from renamed
