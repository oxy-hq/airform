with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        cost
,        weight
,        price
,        supplier_id
,        category
    from source
)
select * from renamed
