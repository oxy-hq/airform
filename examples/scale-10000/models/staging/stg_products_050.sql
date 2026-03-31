with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        sku
,        status
,        price
,        product_name
,        created_at
,        category
,        supplier_id
    from source
)
select * from renamed
