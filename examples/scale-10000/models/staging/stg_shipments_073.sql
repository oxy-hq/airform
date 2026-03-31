with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        delivered_at
,        status
,        shipped_at
,        tracking_number
,        weight
,        warehouse_id
,        cost
    from source
)
select * from renamed
