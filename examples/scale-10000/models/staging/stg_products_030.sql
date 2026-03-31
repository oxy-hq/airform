with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        weight
,        supplier_id
,        created_at
,        status
    from source
)
select * from renamed
