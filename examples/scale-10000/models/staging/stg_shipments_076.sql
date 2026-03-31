with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        tracking_number
,        shipped_at
,        carrier
    from source
)
select * from renamed
