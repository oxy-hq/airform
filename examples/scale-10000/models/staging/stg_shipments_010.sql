with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        warehouse_id
,        cost
,        carrier
,        weight
    from source
)
select * from renamed
