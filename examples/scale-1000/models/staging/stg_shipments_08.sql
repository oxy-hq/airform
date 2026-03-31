with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),

renamed as (
    select
        id as shipment_id
,        shipped_at
,        carrier
,        status
,        order_id
,        weight
    from source
)

select * from renamed
