with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        carrier
,        order_id
,        weight
,        warehouse_id
,        shipped_at
,        status
    from source
)
select * from renamed
