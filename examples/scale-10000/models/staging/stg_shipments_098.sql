with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        order_id
,        carrier
,        status
,        delivered_at
    from source
)
select * from renamed
