with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),

renamed as (
    select
        id as shipment_id
,        weight
,        order_id
,        shipped_at
    from source
)

select * from renamed
