with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        sku
,        status
,        created_at
,        category
,        weight
,        supplier_id
,        product_name
    from source
)
select * from renamed
