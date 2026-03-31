with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        tracking_number
,        warehouse_id
,        delivered_at
,        carrier
    from source
)
select * from renamed
