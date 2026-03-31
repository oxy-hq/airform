with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        sku
,        status
,        weight
,        category
,        created_at
    from source
)
select * from renamed
