with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        cost
,        status
,        weight
,        carrier
,        delivered_at
,        shipped_at
    from source
)
select * from renamed
