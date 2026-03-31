with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        sku
,        weight
,        created_at
,        supplier_id
    from source
)
select * from renamed
