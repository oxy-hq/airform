with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        delivered_at
,        order_id
,        cost
,        shipped_at
,        tracking_number
    from source
)
select * from renamed
