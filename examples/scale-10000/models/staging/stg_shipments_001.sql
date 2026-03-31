with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        warehouse_id
,        cost
,        order_id
,        carrier
,        delivered_at
    from source
)
select * from renamed
