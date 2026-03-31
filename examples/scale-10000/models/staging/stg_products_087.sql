with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        supplier_id
,        product_name
,        sku
,        weight
    from source
)
select * from renamed
