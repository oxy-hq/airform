with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        delivered_at
,        shipped_at
,        weight
,        cost
,        order_id
    from source
)
select * from renamed
