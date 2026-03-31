with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        shipped_at
,        weight
,        order_id
    from source
)
select * from renamed
