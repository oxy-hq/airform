with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        category
,        product_name
,        weight
,        status
,        cost
    from source
)
select * from renamed
