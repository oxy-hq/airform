with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        total_price
,        quantity
,        product_id
,        shipped_at
,        order_id
,        sku
    from source
)
select * from renamed
