with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        weight
,        product_name
,        cost
,        supplier_id
,        created_at
    from source
)
select * from renamed
