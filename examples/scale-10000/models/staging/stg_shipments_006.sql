with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        carrier
,        weight
,        shipped_at
,        tracking_number
,        cost
,        warehouse_id
,        delivered_at
    from source
)
select * from renamed
