with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        order_id
,        delivered_at
,        status
,        carrier
,        cost
    from source
)
select * from renamed
