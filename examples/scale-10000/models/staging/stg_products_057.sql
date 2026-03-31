with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        product_name
,        status
,        price
    from source
)
select * from renamed
