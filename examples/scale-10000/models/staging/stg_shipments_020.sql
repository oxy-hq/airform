with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        weight
,        warehouse_id
,        tracking_number
    from source
)
select * from renamed
