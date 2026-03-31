with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        quantity
,        status
,        shipped_at
,        product_id
,        total_price
,        sku
,        discount
    from source
)

select * from renamed
