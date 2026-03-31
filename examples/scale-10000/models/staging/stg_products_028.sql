with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        cost
,        status
,        sku
,        weight
,        supplier_id
,        category
,        created_at
    from source
)
select * from renamed
