with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        sku
,        created_at
,        product_name
,        price
    from source
)
select * from renamed
