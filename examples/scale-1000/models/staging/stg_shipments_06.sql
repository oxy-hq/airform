with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),

renamed as (
    select
        id as shipment_id
,        carrier
,        warehouse_id
,        shipped_at
,        tracking_number
,        cost
,        order_id
    from source
)

select * from renamed
