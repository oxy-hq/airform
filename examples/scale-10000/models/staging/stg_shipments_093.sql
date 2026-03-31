with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        delivered_at
,        weight
,        tracking_number
,        cost
,        status
,        warehouse_id
    from source
)
select * from renamed
