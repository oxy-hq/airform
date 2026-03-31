with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        created_at
,        category
,        price
,        product_name
,        supplier_id
,        cost
,        sku
    from source
)
select * from renamed
