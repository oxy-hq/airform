with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        id as product_id
,        status
,        weight
,        created_at
,        category
,        sku
    from source
)

select * from renamed
