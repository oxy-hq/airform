with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        carrier
,        shipped_at
,        weight
,        delivered_at
    from source
)
select * from renamed
