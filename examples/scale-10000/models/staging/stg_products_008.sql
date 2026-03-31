with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        price
,        created_at
,        product_name
,        weight
    from source
)
select * from renamed
