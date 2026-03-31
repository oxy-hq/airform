with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        created_at
,        supplier_id
,        cost
,        weight
    from source
)
select * from renamed
