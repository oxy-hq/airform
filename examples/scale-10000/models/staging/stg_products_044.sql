with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        status
,        cost
,        category
,        sku
,        weight
,        created_at
    from source
)
select * from renamed
