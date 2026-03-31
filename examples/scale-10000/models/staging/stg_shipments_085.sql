with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        cost
,        shipped_at
,        weight
,        carrier
    from source
)
select * from renamed
