with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        weight
,        product_name
,        supplier_id
,        status
    from source
)
select * from renamed
