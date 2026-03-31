with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        cost
,        sku
,        status
,        supplier_id
,        weight
    from source
)
select * from renamed
