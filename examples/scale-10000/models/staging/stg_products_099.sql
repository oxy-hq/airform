with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        supplier_id
,        created_at
,        sku
,        cost
    from source
)
select * from renamed
