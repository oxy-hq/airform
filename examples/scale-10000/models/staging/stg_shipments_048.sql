with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        delivered_at
,        order_id
,        carrier
,        shipped_at
    from source
)
select * from renamed
