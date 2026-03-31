with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        supplier_id
,        status
,        product_name
,        sku
    from source
)
select * from renamed
