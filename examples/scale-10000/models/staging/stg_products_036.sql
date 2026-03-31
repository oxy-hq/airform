with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        category
,        status
,        product_name
,        cost
    from source
)
select * from renamed
