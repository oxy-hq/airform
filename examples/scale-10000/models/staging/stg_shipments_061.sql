with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        delivered_at
,        status
,        warehouse_id
,        tracking_number
,        order_id
    from source
)
select * from renamed
