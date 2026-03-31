with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        status
,        tracking_number
,        delivered_at
,        cost
,        warehouse_id
    from source
)
select * from renamed
