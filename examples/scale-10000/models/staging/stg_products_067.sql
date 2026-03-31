with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        weight
,        status
,        cost
,        category
,        product_name
,        supplier_id
    from source
)
select * from renamed
