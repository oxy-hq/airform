with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        order_id
,        warehouse_id
,        shipped_at
    from source
)
select * from renamed
