with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        id as product_id
,        product_name
,        weight
,        supplier_id
,        price
,        cost
    from source
)

select * from renamed
