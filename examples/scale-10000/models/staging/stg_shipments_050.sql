with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        carrier
,        order_id
,        tracking_number
,        shipped_at
,        delivered_at
,        cost
,        weight
    from source
)
select * from renamed
