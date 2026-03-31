with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        weight
,        price
,        supplier_id
,        status
,        created_at
    from source
)
select * from renamed
