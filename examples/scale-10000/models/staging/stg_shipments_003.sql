with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        delivered_at
,        cost
,        carrier
,        shipped_at
,        tracking_number
,        warehouse_id
    from source
)
select * from renamed
