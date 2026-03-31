with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        product_name
,        category
,        weight
    from source
)
select * from renamed
