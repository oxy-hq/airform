with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        status
,        sku
,        category
    from source
)
select * from renamed
