with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        status
,        product_name
,        cost
,        category
,        weight
,        sku
,        created_at
    from source
)
select * from renamed
