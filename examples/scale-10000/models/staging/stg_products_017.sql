with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        cost
,        weight
,        status
,        sku
,        category
    from source
)
select * from renamed
