with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        shipped_at
,        tracking_number
,        carrier
,        order_id
,        delivered_at
    from source
)
select * from renamed
