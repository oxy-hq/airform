with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        order_id
,        warehouse_id
,        weight
,        carrier
,        status
,        shipped_at
    from source
)
select * from renamed
