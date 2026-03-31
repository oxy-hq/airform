with source as (
    select * from {{ source('raw', 'raw_shipments') }}
),
renamed as (
    select
        id as shipment_id
,        shipped_at
,        delivered_at
,        cost
,        status
    from source
)
select * from renamed
