with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        price
,        status
,        product_name
,        sku
    from source
)
select * from renamed
