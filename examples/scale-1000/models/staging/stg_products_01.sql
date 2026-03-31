with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        id as product_id
,        cost
,        sku
,        status
,        category
,        supplier_id
    from source
)

select * from renamed
