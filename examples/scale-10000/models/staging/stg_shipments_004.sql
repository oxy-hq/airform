with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        order_id
,        carrier
,        shipped_at
,        delivered_at
,        warehouse_id
,        cost
,        weight
    from source
)
select * from renamed
