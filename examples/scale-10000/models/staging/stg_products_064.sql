with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        cost
,        weight
,        product_name
,        price
,        sku
,        supplier_id
    from source
)
select * from renamed
