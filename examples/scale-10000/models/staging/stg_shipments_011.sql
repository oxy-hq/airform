with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        delivered_at
,        order_id
,        warehouse_id
    from source
)
select * from renamed
