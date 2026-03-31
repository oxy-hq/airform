with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        carrier
,        weight
,        delivered_at
,        cost
,        order_id
    from source
)
select * from renamed
