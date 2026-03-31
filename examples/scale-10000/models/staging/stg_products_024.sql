with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        weight
,        cost
,        status
,        product_name
,        sku
,        created_at
,        category
    from source
)
select * from renamed
