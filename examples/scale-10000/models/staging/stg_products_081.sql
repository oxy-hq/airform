with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        supplier_id
,        category
,        status
,        sku
,        product_name
    from source
)
select * from renamed
