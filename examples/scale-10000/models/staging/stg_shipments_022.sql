with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        tracking_number
,        carrier
,        shipped_at
,        status
    from source
)
select * from renamed
