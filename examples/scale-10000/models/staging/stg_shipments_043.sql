with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        weight
,        delivered_at
,        tracking_number
    from source
)
select * from renamed
