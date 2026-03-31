with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        weight
,        supplier_id
,        product_name
,        status
    from source
)
select * from renamed
