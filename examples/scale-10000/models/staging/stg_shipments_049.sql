with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        warehouse_id
,        tracking_number
,        shipped_at
,        carrier
,        order_id
    from source
)
select * from renamed
