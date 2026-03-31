with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        product_id
,        quantity
,        status
,        order_id
,        shipped_at
,        sku
,        total_price
    from source
)

select * from renamed
