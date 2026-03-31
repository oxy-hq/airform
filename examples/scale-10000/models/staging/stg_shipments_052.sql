with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        cost
,        warehouse_id
,        delivered_at
,        carrier
,        order_id
,        tracking_number
    from source
)
select * from renamed
