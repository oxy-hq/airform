with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        order_id
,        carrier
,        tracking_number
    from source
)
select * from renamed
