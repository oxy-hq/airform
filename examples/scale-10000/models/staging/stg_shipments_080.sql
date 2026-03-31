with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        shipped_at
,        status
,        order_id
    from source
)
select * from renamed
