with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        warehouse_id
,        shipped_at
,        status
,        carrier
,        tracking_number
    from source
)
select * from renamed
