with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        created_at
,        weight
,        product_name
,        status
,        sku
    from source
)
select * from renamed
