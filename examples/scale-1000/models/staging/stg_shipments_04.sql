with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),

renamed as (
    select
        id as shipment_id
,        cost
,        carrier
,        warehouse_id
,        shipped_at
,        status
,        tracking_number
,        delivered_at
    from source
)

select * from renamed
