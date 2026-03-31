with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        carrier
,        order_id
,        cost
,        weight
,        delivered_at
    from source
)
select * from renamed
