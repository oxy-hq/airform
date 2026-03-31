with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        tracking_number
,        shipped_at
,        weight
    from source
)
select * from renamed
