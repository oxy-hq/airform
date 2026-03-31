with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        carrier
,        tracking_number
,        order_id
,        shipped_at
,        delivered_at
    from source
)
select * from renamed
