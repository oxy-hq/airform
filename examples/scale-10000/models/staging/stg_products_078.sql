with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        status
,        product_name
,        sku
,        weight
,        cost
    from source
)
select * from renamed
