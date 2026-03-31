with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        created_at
,        price
,        product_name
,        sku
,        weight
    from source
)
select * from renamed
