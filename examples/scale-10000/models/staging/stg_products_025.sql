with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        status
,        category
,        price
,        supplier_id
,        cost
,        sku
,        product_name
    from source
)
select * from renamed
