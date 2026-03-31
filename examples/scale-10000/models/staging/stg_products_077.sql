with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        supplier_id
,        sku
,        status
,        cost
,        created_at
,        weight
    from source
)
select * from renamed
