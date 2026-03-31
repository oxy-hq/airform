with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        product_name
,        sku
,        cost
,        created_at
    from source
)
select * from renamed
