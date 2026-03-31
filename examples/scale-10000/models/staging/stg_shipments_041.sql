with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        cost
,        weight
,        delivered_at
,        tracking_number
,        shipped_at
,        warehouse_id
    from source
)
select * from renamed
