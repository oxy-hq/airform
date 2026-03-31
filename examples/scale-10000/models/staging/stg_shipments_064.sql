with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        shipped_at
,        tracking_number
,        carrier
    from source
)
select * from renamed
