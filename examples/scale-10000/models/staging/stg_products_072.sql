with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        product_name
,        price
,        category
,        sku
,        cost
,        supplier_id
    from source
)
select * from renamed
