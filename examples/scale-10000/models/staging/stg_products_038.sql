with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        product_name
,        category
,        weight
,        status
,        supplier_id
,        created_at
,        cost
    from source
)
select * from renamed
