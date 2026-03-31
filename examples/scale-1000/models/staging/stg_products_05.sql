with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        id as product_id
,        created_at
,        status
,        supplier_id
    from source
)

select * from renamed
