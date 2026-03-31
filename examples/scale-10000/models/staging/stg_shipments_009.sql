with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        weight
,        carrier
,        order_id
,        shipped_at
,        status
    from source
)
select * from renamed
