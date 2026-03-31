with source as (
    select * from {{ source('raw', 'raw_products') }}
),
renamed as (
    select
        id as product_id
,        weight
,        category
,        created_at
,        cost
    from source
)
select * from renamed
