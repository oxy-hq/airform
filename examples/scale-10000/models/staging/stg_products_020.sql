with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        weight
,        product_name
,        created_at
,        cost
,        sku
,        category
    from source
)
select * from renamed
