with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        delivered_at
,        warehouse_id
,        carrier
,        cost
    from source
)
select * from renamed
