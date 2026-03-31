with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        delivered_at
,        shipped_at
,        warehouse_id
,        tracking_number
,        weight
,        order_id
,        cost
    from source
)
select * from renamed
