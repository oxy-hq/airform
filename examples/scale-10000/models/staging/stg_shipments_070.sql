with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        carrier
,        order_id
,        delivered_at
,        shipped_at
    from source
)
select * from renamed
