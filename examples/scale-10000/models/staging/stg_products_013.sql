with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        weight
,        created_at
,        supplier_id
,        status
,        sku
,        cost
    from source
)
select * from renamed
