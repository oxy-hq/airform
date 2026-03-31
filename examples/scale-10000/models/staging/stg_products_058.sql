with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        status
,        category
,        product_name
,        supplier_id
,        created_at
,        cost
,        weight
    from source
)
select * from renamed
