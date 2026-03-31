with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        order_id
,        shipped_at
,        tracking_number
,        warehouse_id
,        delivered_at
,        cost
    from source
)
select * from renamed
