with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        id as product_id
,        status
,        created_at
,        cost
,        supplier_id
,        sku
,        category
    from source
)

select * from renamed
