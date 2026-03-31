with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        category
,        supplier_id
,        created_at
,        status
,        sku
,        weight
    from source
)
select * from renamed
