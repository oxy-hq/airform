with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        shipped_at
,        sku
,        total_price
,        product_id
,        order_id
,        quantity
    from source
)
select * from renamed
