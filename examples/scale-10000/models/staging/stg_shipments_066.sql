with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        weight
,        warehouse_id
,        tracking_number
,        cost
,        shipped_at
    from source
)
select * from renamed
