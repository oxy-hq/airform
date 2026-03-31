with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        supplier_id
,        price
,        sku
,        created_at
,        product_name
    from source
)
select * from renamed
