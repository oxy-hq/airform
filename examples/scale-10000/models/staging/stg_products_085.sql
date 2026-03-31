with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        status
,        created_at
,        sku
,        product_name
,        cost
,        supplier_id
,        category
    from source
)
select * from renamed
