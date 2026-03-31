with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        product_name
,        weight
,        sku
,        status
    from source
)
select * from renamed
