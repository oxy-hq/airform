with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        created_at
,        cost
,        product_name
,        weight
,        price
,        supplier_id
    from source
)
select * from renamed
