with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        warehouse_id
,        carrier
,        weight
,        cost
,        shipped_at
,        delivered_at
    from source
)
select * from renamed
