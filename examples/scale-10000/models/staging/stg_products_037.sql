with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        supplier_id
,        created_at
,        sku
,        status
,        product_name
    from source
)
select * from renamed
