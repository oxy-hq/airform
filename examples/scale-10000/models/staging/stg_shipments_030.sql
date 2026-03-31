with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        warehouse_id
,        tracking_number
,        weight
,        carrier
    from source
)
select * from renamed
