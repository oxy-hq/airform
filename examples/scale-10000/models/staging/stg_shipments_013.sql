with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        shipped_at
,        order_id
,        weight
,        carrier
    from source
)
select * from renamed
