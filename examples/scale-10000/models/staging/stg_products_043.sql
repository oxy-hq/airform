with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        supplier_id
,        price
,        product_name
,        weight
,        status
    from source
)
select * from renamed
