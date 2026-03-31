with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        shipped_at
,        cost
,        order_id
,        warehouse_id
,        delivered_at
    from source
)
select * from renamed
