with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        created_at
,        product_name
,        sku
,        supplier_id
,        cost
    from source
)
select * from renamed
