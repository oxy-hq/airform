with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        delivered_at
,        carrier
,        cost
,        warehouse_id
    from source
)
select * from renamed
