with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        quantity
,        sku
,        unit_price
,        product_id
,        status
,        total_price
    from source
)

select * from renamed
