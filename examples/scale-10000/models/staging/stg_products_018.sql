with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        sku
,        weight
,        category
    from source
)
select * from renamed
