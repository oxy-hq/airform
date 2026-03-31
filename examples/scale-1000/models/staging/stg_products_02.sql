with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        id as product_id
,        category
,        weight
,        sku
,        cost
,        created_at
,        status
    from source
)

select * from renamed
