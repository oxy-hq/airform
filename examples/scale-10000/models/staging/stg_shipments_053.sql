with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        order_id
,        shipped_at
,        tracking_number
,        status
,        warehouse_id
    from source
)
select * from renamed
