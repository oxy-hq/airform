with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        warehouse_id
,        tracking_number
,        weight
    from source
)
select * from renamed
