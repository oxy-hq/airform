with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        status
,        weight
,        shipped_at
,        cost
    from source
)
select * from renamed
