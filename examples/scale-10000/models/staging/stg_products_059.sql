with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        product_name
,        weight
,        price
,        category
,        sku
,        status
,        cost
    from source
)
select * from renamed
