with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        tracking_number
,        order_id
,        delivered_at
    from source
)
select * from renamed
