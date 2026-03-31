with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        product_name
,        supplier_id
,        category
,        status
,        cost
,        weight
    from source
)
select * from renamed
