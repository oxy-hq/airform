with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        order_id
,        tracking_number
,        status
,        weight
    from source
)
select * from renamed
