with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        status
,        weight
,        product_name
,        category
    from source
)
select * from renamed
